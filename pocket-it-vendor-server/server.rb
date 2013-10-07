require "rubygems"
require "bundler/setup"
require 'goliath'
require 'mysql2'
require 'em-synchrony/activerecord'
require 'grape'
require "./tree"

class Application < Goliath::API
	def response(env)
	  ::PocketAPI::Authentication::User.call(env)
	end
end