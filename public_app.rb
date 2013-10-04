require 'bundler/setup'
require 'sinatra/base'
require 'omniauth-facebook'
require 'dotenv'
require 'uri'
require 'twilio-ruby'
require 'mongo_mapper'
require 'pry'

require "./models"

Dotenv.load

SCOPE = 'email'

class PublicApp < Sinatra::Base
	set :protection, :except => :frame_options
	
	configure do
		mongo_url = ENV['MONGOHQ_URL'] || 'mongodb://localhost/dbname'
 
		MongoMapper.connection = Mongo::Connection.from_uri mongo_url
		MongoMapper.database = URI.parse(mongo_url).path.gsub(/^\//, '') #Extracts 'dbname' from the uri
	end

	helpers do
		def set_session
			session["auth"] = request.env['omniauth.auth']
		end

		def auth_hash
			@auth_hash ||= session["auth"]
		end

		def user_is_recognized?
			# TODO: Check to make sure the user is in the known user list
			true
		end

		def web_authenticate
			#/auth/facebook?display=popup
			redirect '/auth/facebook' unless auth_hash
			halt 401, "Not Authorized" unless user_is_recognized?
		end

		def api_authenticate

		end

		def twilio_auth(twilio_id, sneder)
			# TODO: Check to make sure the sender number is recognized
			halt 401 unless twilio_id == ENV["TWILIO_ACCOUNT_ID"]
		end

		def twilio_client
			@twilio_client ||= Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_ID"], ENV["TWILIO_AUTH_TOKEN"]
		end

		def send_text (message)
			message = twilio_client.account.messages.create(:body => "Jenny please?! I love you <3",
    		:to => ENV["TEST_PHONE"],
    		:from => ENV["TWILIO_NUMBER"])
		end

		def query_door_status
			DoorStatus.first(:order => :created_at.desc).is_open
		end

		def queue_open_request
			if not query_door_status and not Job.exists
				Job.create(:type => 'open')
				"Opening the door"
			else
				"Door is already open"
			end
		end

		def queue_close_request
			if query_door_status and not Job.exists
				Job.create(:type => 'close')
				"Closing the door"
			else
				"Door is already closed"
			end
		end

		def route_sms (message)
			message = message.downcase.chomp
			if message == "status"
				query_door_status
			elsif message == "close"
				queue_close_request
			elsif message == "open"
				queue_open_request
			end
		end
	end

	get '/' do
		web_authenticate
		"The garage door is #{query_door_status ? "open" : "closed"}"
	end

	get '/logout' do
		session['auth'] = nil
		@auth_hash = nil
		redirect '/'
	end

	get '/auth/:provider/callback' do
		set_session
		web_authenticate
		redirect '/'
	end

	# HANDLE TWILIO MESSAGES
	post '/twilio/message/recieve' do
		twilio_auth params[:AccountSid], "FakeSender"

		sender = params[:From]
		outgoing_message = route_sms params[:Body]
		response = Twilio::TwiML::Response.new do |r|
			r.Message outgoing_message
		end
		response.text
	end

	# API FOR WORKING WITH THE DOOR CONTROLLER
	get '/door/jobs' do
		api_authenticate
		content_type 'application/json'
    
    job = Job.first(:order => :created_at.desc)
    job.started = true
    job.save!
    MultiJson.encode(job)		
	end
	
	post '/door/job/:id' do
		api_authenticate
		js = MultiJson.load(request.body.read, :symbolize_keys => true)
		binding.pry
		if js[:success] == true
			job = Job.find_by_id(params[:id])
			job.finished = true
			job.save!
			DoorStatus.create(:is_open => js[:is_open])
			send_text "The door has #{js[:is_open] ? "opened" : "closed"}."
		else
			# Requeue the job and notify
			job = Job.find_by_id(params[:id])
			job.started = false
			job.save!
			send_text "Failed while trying to #{job.type} the door."
		end
	end

	post '/door/status/:status' do
		api_authenticate
		DoorStatus.create(:is_open => params[:status])
	end
end
