require 'pi_piper'
require 'timeout'
require './api_client'

include PiPiper

api_client = ApiClient.new

sensor_pin = PiPiper::Pin.new pin: 10, direction: :in, invert: true
motor_pin = PiPiper::Pin.new pin: 7, direction: :out, pull: :up
override_pin = PiPiper::Pin.new pin: 0, direction: :in, invert: true

after :pin => 10, :goes => :high do
  puts "Door open. Waiting..."
  sleep 60 * 15
  if sensor_pin.read == 1 and override_pin.read == 0
    puts "Auto Closing"
    motor_pin.on
    sleep 5
    motor_pin.off
    api_client.auto_close
    api_client.send_status(sensor_pin.read == 1)
  elsif override_pin.read == 1
    puts "Override activated."
  else
    puts "Door closed in time"
  end
end

PiPiper.wait
