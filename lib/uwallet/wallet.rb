# frozen_string_literal: true

module UWallet
  # Main class for operations with wallet and transactions
  class Wallet
    include Bitcoin::Builder

    def initialize(api, key)
      @api = api
      @key = key
    end

    def balance
      utxo = @api.get_utxo_by_address(@key.addr)
      utxo.map { |t| t['value'] }.reduce(0, :+).to_f
    end

    # Send money from key wallet to some address
    #
    # First, we create a transaction. Then we count the bytes in it.
    # Then we read the commission and create the transaction again
    def send_money(sending_sum, receiver_addr)
      utxo = @api.get_utxo_by_address(@key.addr)
      cashback_with_fee = balance - sending_sum
      raise Errors::InsufficientFunds if cashback_with_fee <= 0

      utxo.each do |u|
        u['raw'] = @api.get_binary_transaction(u['txid'])
      end
      receivers = [Receiver.new(receiver_addr, sending_sum), Receiver.new(@key.addr, cashback_with_fee)]
      tx = build_transaction(utxo, receivers)
      fee = Utils.bytes_to_fee(tx.size)
      cashback = cashback_with_fee - fee
      raise Errors::InsufficientFunds if cashback.negative?

      receivers = [Receiver.new(receiver_addr, sending_sum)]
      receivers.append(Receiver.new(@key.addr, cashback)) if cashback.positive?
      tx = build_transaction(utxo, receivers)
      res = @api.post_transaction(tx.to_payload.unpack1('H*'))
      Log.logger.info 'Success!'
      Log.logger.info "Transaction ID: #{res}"
      Log.logger.info format('Sent amount: %.8f BTC', Utils.satoshi_to_btc(sending_sum))
      Log.logger.info format('Cashback: %.8f BTC', Utils.satoshi_to_btc(cashback))
      Log.logger.info format('Fee: %.8f BTC', Utils.satoshi_to_btc(fee.to_f))
    end

    private

    def build_transaction(utxo, receivers)
      build_tx do |t|
        utxo.each do |u|
          t.input do |i|
            i.prev_out Bitcoin::Protocol::Tx.new(u['raw'])
            i.prev_out_index u['vout']
            i.signature_key @key
          end
        end
        receivers.each do |receiver|
          t.output do |o|
            o.value receiver.sum
            o.script { |s| s.recipient receiver.addr }
          end
        end
      end
    end
  end
end
