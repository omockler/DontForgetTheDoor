require 'bundler/setup'
require 'sinatra/base'
require 'omniauth-facebook'
require './web/public_app'

SCOPE = 'email'

use Rack::Session::Cookie

use OmniAuth::Builder do
	provider :facebook, ENV['APP_ID'], ENV['APP_SECRET'], :scope => SCOPE, :auth_type => 'reauthenticate'
end

run PublicApp.new
