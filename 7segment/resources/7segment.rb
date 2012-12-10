#! /usr/bin/ruby
#

PHATIO=ENV['PHATIO']
TIME="#{PHATIO}/io/dev/time"
NUMBER="#{PHATIO}/io/dev/number"

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


puts "counting number with phatIO doing digit mapping"
0.upto(9999) { |i| 
  write_to_file(NUMBER, "%4d" % i)
  sleep 0.5
}

