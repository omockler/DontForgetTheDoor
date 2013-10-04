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
  after_create :create_status

  timestamps!

  private
  def create_status 
    DoorStatus.create(:is_open => false)
  end
end
