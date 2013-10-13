require 'mongo_mapper'

class Job
	include MongoMapper::Document

	key :type, String
	key :started, Boolean, :default => false
	key :finished, Boolean, :default => false
	timestamps!

	def self.exists
		where(:finished => false).first
	end
end

class DoorStatus
	include MongoMapper::Document

	key :is_open, Boolean
	timestamps!
end

class AutoCloseEvent
  include MongoMapper::Document

  timestamps!
end

class User
  include MongoMapper::Document

  key :email, String
  key :phone, String
  key :authorized, Boolean, :default => false
  key :admin, Boolean, :default => false
end
