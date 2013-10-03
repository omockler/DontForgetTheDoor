require 'bundler/setup'
require 'sinatra/base'
require 'omniauth-facebook'
require './public_app'

SCOPE = 'email,read_stream'

use Rack::Session::Cookie

use OmniAuth::Builder do
	provider :facebook, ENV['APP_ID'], ENV['APP_SECRET'], :scope => SCOPE, :auth_type => 'reauthenticate'
end

run PublicApp.new
