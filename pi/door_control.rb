require 'faraday'
require 'json'
require 'pry'

class DoorApi
  def initialize
    @conn = Faraday.new(:url => 'http://localhost:9292') do |faraday|
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
  end

  def get_job
    job = @conn.get('/door/jobs').body
    if job.empty? then nil else JSON.parse job end
  end

  def finish_job(id, success, is_open)
    @conn.post do |req|
      req.url "/door/job/#{id}"
      req.headers['Content-Type'] = 'application/json'
      req.body = %{ {"success": "#{success}", "is_open": "#{is_open}"} }
    end
  end

  def send_status(status)
    @conn.post do |req|
      req.url "/door/status/#{status}"
      req.headers['Content-Type'] = 'application/json'
    end
  end

  def auto_close
    @conn.post do |req|
      req.url "/door/auto-close}"
      req.headers['Content-Type'] = 'application/json'
    end
  end
end