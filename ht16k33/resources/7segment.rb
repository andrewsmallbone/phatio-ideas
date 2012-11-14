#! /usr/bin/ruby
# phatIO ht16k33 7 segment demo
# see http://www.phatio.com/ideas/ht16k33/
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


puts "counting time with phatIO doing digit mapping"
10.downto(0) { |mins| 
  59.downto(0) { |secs| 
      write_to_file(TIME, "%02d" % mins + "%02d" % secs)
      # sleep 0.02
  }
}
  
puts "counting number with phatIO doing digit mapping"
1999.downto(0) { |i| 
  write_to_file(NUMBER, "%4d" % i)
  # sleep 0.01
}

