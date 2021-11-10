#!/usr/bin/env ruby
# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))
require 'uwallet'

begin
  Dry::CLI.new(UWallet::CLI).call
rescue UWallet::Errors::AppError => e
  UWallet::Log.logger.error "Error: #{e.message}"
rescue UWallet::Errors::InsufficientFunds
  puts 'Not enough money in the wallet for transfer'
rescue StandardError => e
  UWallet::Log.logger.fatal e
end
