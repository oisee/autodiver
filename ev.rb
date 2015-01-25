
require 'fileutils'
require 'RMagick'
#gem 'RMagick'

folder = Dir["./evaluate/*.png"]

class Ev

  def self.evaluate(file)

    @@img = Magick::Image::read(file).first
    err = 0

    for y in 0..23
      for x in 0..31
       err = err + cell(x*8, y*8)
      end
    end
    return err
  end
  def self.cell(px,py)
    cell = @@img.get_pixels(px,py,8,8)
    rcell = cell.reduce(Hash.new(0)) {|a,b| a[b] += 1;a}
    #print "#{rcell.inspect}\n"
    acell = rcell.values.sort.reverse[2,64]
    bcell = acell != nil ? acell : [0]
    #print "#{acell.inspect} => #{bcell.inspect}\n"
    err = bcell.inject(0, &:+)
    return err
  end
end

result_file = "./result.csv"
File.delete(result_file) if File.exist?(result_file)
rfile = File.open(result_file,"w")

best_file = "./best.csv"
File.delete(best_file) if File.exist?(best_file)
bfile = File.open(best_file,"w")

result = Hash.new
for file in folder
  print "#{file}"
  begin
  err = Ev.evaluate(file)

  print ", #{err}\n"
  rfile.print "#{file}, #{err}\n"
  result[file] = err

  rescue RangeError => e
  end
end

sresult = result.sort_by {|k, v| v}.to_h

sresult.each {|k,v|
  bfile.print "#{k}, #{v}\n"
}