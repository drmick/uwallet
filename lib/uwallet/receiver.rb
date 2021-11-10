# frozen_string_literal: true

module UWallet
  # Receiver model for transaction
  class Receiver
    attr_accessor :addr, :sum

    def initialize(addr, sum)
      @addr = addr
      @sum = sum
    end
  end
end
