require 'pi_piper'
require 'timeout'
require './api_client'

include PiPiper

api_client = ApiClient.new

watch :pin => 17 do
  api_client.send_status(value == 1)
end

after :pin => 17, :goes => :low do
  puts "Door open. Waiting..."
  begin
    Timeout.timeout(30) {
      pin = PiPiper::Pin.new :pin => 17, :direction => :in
      pin.wait_for_change
      puts "Door closed in time."
    }
   rescue
     puts "Auto closing"
     api_client.auto_close
   end
end

PiPiper.wait