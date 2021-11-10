# frozen_string_literal: true

require 'dry/cli'
require 'bitcoin'
require 'json'
require 'logger'
require_relative 'uwallet/api'
require_relative 'uwallet/cli'
require_relative 'uwallet/errors'
require_relative 'uwallet/utils'
require_relative 'uwallet/conf'
require_relative 'uwallet/log'
require_relative 'uwallet/wallet'
require_relative 'uwallet/receiver'

# Main module with configuration
module UWallet
  UWallet::Conf.configure do |config|
    config.key_path = ENV['UWALLET_KEY'] if ENV['UWALLET_KEY']
    config.network = ENV['UWALLET_NETWORK'] if ENV['UWALLET_NETWORK']
  end
  UWallet::Log.logger = Logger.new($stdout)
  Bitcoin.network = Conf.configuration.network
end
