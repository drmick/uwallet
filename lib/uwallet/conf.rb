# frozen_string_literal: true

require_relative 'conf/configuration'
module UWallet
  # Global configuration
  module Conf
    class << self
      attr_accessor :configuration
    end

    def self.configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end
end
