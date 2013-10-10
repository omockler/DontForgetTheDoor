require 'pi_piper'
require './api_client'

api = WebApi.new

job = api.get_job
opener_pin = PiPiper::Pin.new :pin => 23, :direction => :out
status_pin = PiPiper::Pin.new :pin => 17, :direction => :in

return unless job

# Dont process the job if the door is already in the desired state.
# TODO: Close put job with fail
return if job["type"] == "open" and status_pin.off?
return if job["type"] == "closed" and status_pin.on?

opener_pin.on

sleep 30 # or however long it takes for the door to open / close

# ensure door status

api.finish_job job["id"], true, status_pin.off?