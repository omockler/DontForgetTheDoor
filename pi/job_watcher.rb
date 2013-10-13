require 'pi_piper'
require './api_client'

motor_pin = PiPiper::Pin.new pin: 7, direction: :out, pull: :up
sensor_pin = PiPiper::Pin.new pin: 10, direction: :in, invert: true
override_pin = PiPiper::Pin.new pin: 0, direction: :in, invert: true

api_client = ApiClient.new

loop do
  sleep 60
  
  api_client.send_status(sensor_pin.on?)

  job = api_client.get_job

  next unless job

  # Dont process the job if the door is already in the desired state.
  # TODO: Close put job with fail

  next if job["type"] == "open" and sensor_pin.on?
  next if job["type"] == "closed" and sensor_pin.off?

  motor_pin.on
  sleep 5
  motor_pin.off

  # ensure door status
  api_client.finish_job job["id"], true, sensor_pin.off?  
end
