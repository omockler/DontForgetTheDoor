require 'pi_piper'
require 'timeout'
require './api_client'

include PiPiper

api_client = ApiClient.new

watch :pin => 10 do
  api_client.send_status(value != 1)
end

after :pin => 10, :goes => :low do
  puts "Door open. Waiting..."
  begin
    Timeout.timeout(60) {
      pin = PiPiper::Pin.new(:pin => 10, :direction => :in)
      pin.wait_for_change
      puts "Door closed in time."
    }
   rescue
     puts "Auto closing"
     door_pin = PiPiper::Pin.new(pin: 7, direction: :out, pull: :up)
     door_pin.on
     sleep 5
     door_pin.off
     api_client.auto_close
   end
end

PiPiper.wait
