# frozen_string_literal: true

module UWallet
  # Common utils
  module Utils
    def self.load_key(path)
      raise Errors::AppError, 'Key file not found' unless File.file?(path)

      base58 = File.open(path).read
      Bitcoin::Key.from_base58(base58)
    end

    def self.btc_to_satoshi(val)
      val * 100_000_000
    end

    def self.satoshi_to_btc(val)
      val / 100_000_000
    end

    # Calculate FEE by bytes length. 1 Satoshi == 1 byte.
    #
    # Sometimes the API rejects the transaction due to the fact that the bytes in the transaction
    # are considered differently there (sometimes there is not enough 1 satoshi in the commission)
    def self.bytes_to_fee(bytes_amount)
      correction = 5
      bytes_amount + correction
    end
  end
end
