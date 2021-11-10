# frozen_string_literal: true

module UWallet
  module Conf
    # Configuration class
    class Configuration
      attr_accessor :key_path, :network

      def initialize
        @key_path = 'base58key.txt'
        @network  = 'testnet3'
      end
    end
  end
end
