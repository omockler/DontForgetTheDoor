require 'pi_piper'
require 'timeout'
require './api_client'

include PiPiper

api_client = ApiClient.new

sensor_pin = PiPiper::Pin.new pin: 10, direction: :in, invert: true
motor_pin = PiPiper::Pin.new pin: 7, direction: :out, pull: :up

after :pin => 10, :goes => :low do
  puts "Door open. Waiting..."
  begin
    Timeout.timeout(60) {
      sensor_pin.wait_for_change
      puts "Door closed in time."
    }
   rescue
     puts "Auto closing"
     motor_pin.on
     sleep 5
     motor_pin.off
     api_client.auto_close
     api_client.send_status(sensor_pin.on?)
   end
end

PiPiper.wait
