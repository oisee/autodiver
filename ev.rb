
require 'fileutils'
require 'RMagick'
#gem 'RMagick'

folder = Dir["./evaluate/*.png"]

dir_best = "./best"
unless File.directory?(dir_best)
  FileUtils.mkdir_p(dir_best)
end

class Ev

  def self.evaluate(file)

    @@img = Magick::Image::read(file).first
    print " Geometry: #{@@img.columns}x#{@@img.rows} "
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

result = {}
folder.each{|file|
  print "#{file}"
  begin
    err = Ev.evaluate(file)

    print ", #{err}\n"
    rfile.print "#{file}, #{err}\n"
    result[file] = err

  rescue RangeError => e
    print " -> Error\n"
  end
}

sresult = result.sort_by {|k, v| v}.to_h

best = {}
worst = {}
sresult.each {|k,v|
  if best.count <=3
    best[k]=v
  end
  worst[:path] = k
  worst[:penalty] = v
  bfile.print "#{k}, #{v}\n"
}
print "Best: \n\n"
best.each{|k,v|
  print "#{k} #{v}"
  FileUtils.copy(k,"./best/#{File.basename(k)}")
}
