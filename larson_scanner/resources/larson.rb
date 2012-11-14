#! /usr/bin/ruby
# phatIO larson scanner example
# see http://www.phatio.com/ideas/larson_scanner/
#

BOTTOMLED=0
TOPLED=11

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
  

def flash(pin)
  pin(pin, 1)
  sleep 0.05
  pin(pin, 0)
end

# make all pins outputs
BOTTOMLED.upto(TOPLED) { |pin| mode(pin, "OUT") }

while true
  BOTTOMLED.upto(TOPLED) { |pin| flash(pin)}
  TOPLED.downto(BOTTOMLED) { |pin| flash(pin)}
end

