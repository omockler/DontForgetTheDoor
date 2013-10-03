require 'SolarEventCalculator'

def secondsToTime(endTime)
	((endTime - DateTime.now) * 24 * 60 * 60).to_i
end

date = Date.today
calc = SolarEventCalculator.new(date, BigDecimal.new(ENV["CURRENT_LAT"])), BigDecimal.new(ENV["CURRENT_LONG"]))

riseTime = calc.compute_official_sunrise('America/New_York')
setTime = calc.compute_official_sunset('America/New_York')

# Sleep until sunrise then set the relay to open
sleep secondsToTime riseTime

# TODO: Set the relay open

# Sleep until sunset then set the relay to closed
sleep secondsToTime setTime

# TODO: Set the relay to open
