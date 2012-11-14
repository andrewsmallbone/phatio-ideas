#! /usr/bin/ruby
# phatIO pwm larson scanner example
# see http://www.phatio.com/ideas/larson_scanner/
#

PHATIO=ENV['PHATIO']

def write_to_file(filename, value)
  file = File.open(filename, "w")
  file.write(value)
  file.close
rescue Exception => e
  puts "Failed to write to '#{filename}': #{e}"
  puts "Make sure PHATIO environment variable points to phatIO mount point (currently '#{PHATIO}')"
  file.close unless file == nil
  exit
end

def mode(pin, mode)
  write_to_file("#{PHATIO}/io/mode/#{pin}", mode)
end

def pin(pin, value)
  write_to_file("#{PHATIO}/io/pins/#{pin}", value)
end

# history of which pins have been lit
$trail = [7, 8, 9, 10, 6]
# intensities of LED in trail
$values = [250, 70, 20, 4, 0]

def pulse(pin)
  # shift trail
  4.downto(1) { |x| $trail[x] = $trail[x-1] }
  $trail[0] = pin
  # set new LED intensities
  4.downto(0) { |x| pin($trail[x], $values[x]) }
  sleep 0.1
end  

# pwm are 6 7 8 9 10
6.upto(10) {|p| mode(p, "PWM") }
while true
  [6,7,8,9,10,9,8,7].each{ |x| pulse(x) }
end
