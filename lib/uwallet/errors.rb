# frozen_string_literal: true

module UWallet
  # Custom errors
  module Errors
    class AppError < StandardError
    end

    class InsufficientFunds < StandardError
    end
  end
end
