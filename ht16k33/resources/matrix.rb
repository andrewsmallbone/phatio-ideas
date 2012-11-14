#! /usr/bin/ruby
# phatIO ht16k33 matrix demo
# see http://www.phatio.com/ideas/ht16k33/
#

PHATIO=ENV['PHATIO']
DEVICE="#{PHATIO}/io/dev/ht16k33"
MONO="#{PHATIO}/io/dev/mono"

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


puts "columns and rows"
0.upto(7) do
  0.upto(7) do |x|
    output = ""
    0.upto(7) { |y| output += (x==y) ? "FF" : "00" }
    write_to_file(MONO, output)
    sleep 0.02
  end
  
  0.upto(7) do |x|
    output = ""
    0.upto(7) { |y| output += "%02X" % (0x01 << x) }
    write_to_file(MONO, output)
    sleep 0.02
  end
end
  
#on a colour LED matrix cycle through red (FF00), green (00FF), yellow (FFFF)
puts "colour sweep"
0.upto(5) do
  ["FF00", "00FF", "FFFF"].each do |str|
    0.upto(7) do |x|
      output = ""
      0.upto(7) { |y| output += (x>=y) ? str : "0000" }
      write_to_file(DEVICE, output)
      sleep 0.1
    end
  end
end
  
# random colours
puts "random segments/colours"
0.upto(10) do
  0.upto(7) do |x|
    output = ""
    0.upto(7) { |y| output += "%04X" % rand(0xFFFF) }
    write_to_file(DEVICE, output)
    sleep 0.1
  end
end