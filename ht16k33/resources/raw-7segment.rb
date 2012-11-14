#! /usr/bin/ruby
# phatIO ht16k33 7 segment demo
# see http://www.phatio.com/ideas/ht16k33/
#

PHATIO=ENV['PHATIO']
DEVICE="#{PHATIO}/io/dev/mono"

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



def char_to_7segment(value)
  # map of numbers (hex) to 7 segment display
  keymap = [0x3F, 0x06, 0x5B, 0x4F, 0x66, 0x6D, 0x7D, 0x07, 0x7F, 0x6F, 0x77, 0x7C, 0x39, 0x5E, 0x79, 0x71]
  return (value == 0x20) ? 0x00 : keymap[value - 0x30] 
end


def integer_to_7segment(value)
  display = "%4d" % value  # convert integer to 4 character string prefixed with spaces
  hex_string=""
  0.upto(3) { |i| hex_string += "%02X" % char_to_7segment(display[i]) }
  hex_string.insert(4, "00") # insert empty value for colon in middle of display
  return hex_string
end


puts "counting with raw digit control"
9000.upto(9999) { |x| 
  write_to_file(DEVICE, integer_to_7segment(x));
  #sleep 0.01
}

