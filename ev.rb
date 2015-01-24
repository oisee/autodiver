
require 'fileutils'

folder = Dir["./evaluate/out*.png"]

class Ev
end

for file in folder
  print "#{file}\n"
end