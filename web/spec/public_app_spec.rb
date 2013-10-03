require_relative '../public_app'
require 'rack/test'

set :environment, :test

def app
	Sinatra::Application
end

describe 'Recieve Text Message' do
	include Rack::Test::Methods

	it "Should save the text message" do
		post '/twilio/message/recieve', params = {:param => "value"}
		last_response.should be_ok
		last_response.body.should == ''
	end
end