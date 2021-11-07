#!/usr/bin/env ruby
# frozen_string_literal: true

module App
  require 'dry/cli'
  require 'bitcoin'
  require 'json'
  Bitcoin.network = :testnet3
  $key_path = 'base58key.txt'

  # Catched custom error
  class AppError < StandardError
  end

  # Module with helpers
  module Utils
    # Load keyfile from local path
    def self.load_key(path)
      raise AppError, 'Key file not found' unless File.file?(path)

      base58 = File.open(path).read
      Bitcoin::Key.from_base58(base58)
    end

    # Converter tBTC to Satoshi
    def self.btc_to_satoshi(val)
      val.to_f * 100_000_000
    end

    # Converter Satoshi to tBTC
    def self.satoshi_to_btc(val)
      val.to_f / 100_000_000
    end
  end

  # External API
  class ExternalAPI
    require 'net/http'
    require 'open-uri'

    def initialize
      @base_url = 'https://blockstream.info/testnet/api'
    end

    def get_utxo_by_address(address)
      url = URI.parse("#{@base_url}/address/#{address}/utxo")
      res = Net::HTTP.get URI(url)
      JSON.parse(res)
    end

    def get_binary_transaction(tx_hash)
      uri = URI.parse("#{@base_url}/tx/#{tx_hash}/raw")
      res = Net::HTTP.get URI(uri)
      if res == 'Transaction not found'
        raise AppError,
              "Transaction not found in #{@base_url}. Perhaps the requests are being made too quickly and the data has not yet reached the API server. URI=#{uri}"
      end

      res
    end

    def post_transaction(raw)
      url = URI.parse("#{@base_url}/tx")
      res = Net::HTTP.post(URI(url), raw, { 'Content-type': 'text/plain' })
      raise StandardError, res.body if res.code != '200'

      res.body
    end
  end

  # Main service for operations with wallet and transactions
  class WalletService
    include Bitcoin::Builder
    def get_balance(api, addr)
      utxo = api.get_utxo_by_address(addr)
      utxo.map { |t|  t['value'] }.reduce(0, :+)
    end

    # Send money from key wallet to some address
    def send_money(api,
                   key,
                   amount_to_sent,
                   receiver_addr)
      utxo = api.get_utxo_by_address(key.addr)
      balance = get_balance(api, key.addr)
      cashback_with_fee = balance - amount_to_sent

      raise AppError, 'Insufficient funds' if cashback_with_fee <= 0

      # Get all utxo by key address
      utxo.each do |u|
        u['raw'] = api.get_binary_transaction(u['txid'])
      end

      # Create transaction without fee for calculate length of the transaction bytes
      tx = create_transaction(utxo, key, amount_to_sent, cashback_with_fee, receiver_addr, key.addr)
      # Calc fee by transaction length
      fee = get_fee_by_bytes(tx.size)
      # Exclude fee from cashback
      cashback_without_fee = cashback_with_fee - fee
      raise AppError, 'Insufficient funds' if cashback_without_fee.negative?

      # Create transaction with fee
      tx = create_transaction(utxo, key, amount_to_sent, cashback_without_fee, receiver_addr, key.addr)
      # Broadcast transaction to tBTC network
      res = api.post_transaction(tx.to_payload.unpack1('H*'))

      puts 'Success!'
      puts "Transaction ID: #{res}"
      puts 'Sent amount: %.8f tBTC' % Utils.satoshi_to_btc(amount_to_sent)
      puts 'Cashback: %.8f tBTC' % Utils.satoshi_to_btc(cashback_without_fee)
      puts 'Fee: %.8f tBTC' % Utils.satoshi_to_btc(fee)
    end

    # Calculate FEE by bytes length. 1 Satoshi == 1 byte
    def get_fee_by_bytes(bytes_amount)
      # sometimes the API rejects the transaction due to the fact that the bytes in the transaction
      # are considered differently there (sometimes there is not enough 1 satoshi in the commission)
      correction = 5
      bytes_amount + correction
    end

    # Create transaction
    def create_transaction(utxo, key, send_amount, cashback, receiver_address, cashback_address)
      build_tx do |t|
        utxo.each do |u|
          prev_tx_raw = u['raw']
          prev_tx = Bitcoin::Protocol::Tx.new(prev_tx_raw)
          prev_tx_output_index = u['vout']
          t.input do |i|
            i.prev_out prev_tx
            i.prev_out_index prev_tx_output_index
            i.signature_key key
          end
        end
        t.output do |o|
          o.value send_amount
          o.script { |s| s.recipient receiver_address }
        end
        # Exclude cashback if it is 0
        if cashback.positive?
          t.output do |o|
            o.value cashback
            o.script { |s| s.recipient cashback_address }
          end
        end
      end
    end
  end

  # Command line interface module
  module CLI
    module Commands
      extend Dry::CLI::Registry

      # Generate primary key to file
      class Generate < Dry::CLI::Command
        desc 'Generate primary key'

        def call(*)
          raise App::AppError, "#{$key_path} already exists" if File.file?($key_path)

          key = Bitcoin::Key.generate
          File.open($key_path, 'w') { |file| file.write(key.to_base58) }
          puts "#{$key_path} is created"
        end
      end

      # Print balance
      class Balance < Dry::CLI::Command
        desc 'Print balance'
        def call(*)
          api = ExternalAPI.new
          key = Utils.load_key($key_path)
          balance = WalletService.new.get_balance(api, key.addr)
          puts "Wallet: #{key.addr}"
          puts 'Balance: %.8f tBTC' % Utils.satoshi_to_btc(balance)
        end
      end

      # Print key address
      class GetAddress < Dry::CLI::Command
        desc 'Print key address'
        def call(*)
          key = Utils.load_key($key_path)
          puts key.addr
        end
      end

      # Send money
      class Send < Dry::CLI::Command
        desc 'Send money'
        argument :address, desc: 'Receiver address', required: true
        argument :value, desc: 'Amount in tBTC', required: true

        def call(address: nil, value: nil, **)
          api = ExternalAPI.new
          key = Utils.load_key($key_path)
          value = Utils.btc_to_satoshi(value)
          WalletService.new.send_money(api, key, value.to_f, address)
        end
      end

      register 'generate', Generate
      register 'addr', GetAddress
      register 'balance', Balance
      register 'send', Send
    end
  end
end

begin
  Dry::CLI.new(App::CLI::Commands).call
rescue App::AppError => e
  puts "Error: #{e.message}"
end
