# frozen_string_literal: true

module UWallet
  # Command line interface module
  module CLI
    extend Dry::CLI::Registry

    # Generate primary key to file
    class Generate < Dry::CLI::Command
      desc 'Generate primary key'

      def call(*)
        key_path = Conf.configuration.key_path
        raise Errors::AppError, "#{key_path} already exists" if File.file?(key_path)

        key = Bitcoin::Key.generate
        File.open(key_path, 'w') { |file| file.write(key.to_base58) }
        puts "#{key_path} is created"
      end
    end

    # Print balance
    class Balance < Dry::CLI::Command
      desc 'Print balance'

      def call(*)
        key_path = Conf.configuration.key_path
        key = Utils.load_key(key_path)
        api = External::BitcoinNetworkAPI.new
        balance = Wallet.new(api, key).balance
        puts "Wallet: #{key.addr}"
        puts "Balance: #{Utils.satoshi_to_btc(balance).truncate(8)} BTC"
      end
    end

    # Print key address
    class GetAddress < Dry::CLI::Command
      desc 'Print key address'

      def call(*)
        key_path = Conf.configuration.key_path
        key = Utils.load_key(key_path)
        puts key.addr
      end
    end

    # Send money
    class Send < Dry::CLI::Command
      desc 'Send money'
      argument :address, desc: 'Receiver address', required: true
      argument :send_amount, desc: 'Amount in BTC', required: true

      def call(address: nil, send_amount: nil, **)
        key_path = Conf.configuration.key_path
        key = Utils.load_key(key_path)
        send_amount = Utils.btc_to_satoshi(send_amount.to_f)
        api = External::BitcoinNetworkAPI.new
        wallet = Wallet.new(api, key)
        wallet.send_money(send_amount, address)
      end
    end

    register 'generate', Generate
    register 'addr', GetAddress
    register 'balance', Balance
    register 'send', Send
  end
end
