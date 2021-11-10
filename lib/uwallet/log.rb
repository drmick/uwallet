# frozen_string_literal: true

module UWallet
  # Global logger
  module Log
    def self.logger
      @logger
    end

    def self.logger=(logger)
      @logger = logger
    end
  end
end
