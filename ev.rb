require 'fileutils'
require 'RMagick'

dir_eval = Dir["./eval/*.png"]
dir_eval_mask = "./eval_mask/"
dir_best = "./best"
unless File.directory?(dir_best)
  FileUtils.mkdir_p(dir_best)
end

class Ev
  def initialize
    @black = Magick::Pixel.new(0,0,0,)
    @white =  Magick::Pixel.new(255,255,255)
  end
  def eval_image(file)
    img = Magick::Image::read(file).first
    print " Image: #{img.columns}x#{img.rows} "
    err = 0
    for y in 0..23
      for x in 0..31
       err = err + eval_cell(img, x*8, y*8)
      end
    end
    err
  end
  def eval_cell(img,px,py)
    cell = img.get_pixels(px,py,8,8)
    rcell = cell.reduce(Hash.new(0)) {|a,b| a[b] += 1;a}
    acell = rcell.values.sort.reverse[2,64]
    bcell = acell != nil ? acell : [0]
    err = bcell.inject(0, &:+)
  end

  def eval_image_with_mask(file,file_mask)
    img = Magick::Image::read(file).first
    mask = Magick::Image::read(file_mask).first
    print " Image: #{img.columns}x#{img.rows} / Mask: #{mask.columns}x#{mask.rows} ,"
    if img.columns != mask.columns or img.rows != mask.rows then
      print " Image and Mask are not equal size"
      return 65535
    end
#--------------------------------------------------------
    err = 0
    for y in 0..23
      for x in 0..31
        err = err + eval_cell_with_mask(img,mask,x*8, y*8)
      end
    end
    err
  end
  def eval_cell_with_mask(img, mask, px, py)
    cell_mask = mask.get_pixels(px,py,8,8)
    rcell_mask = cell_mask.reduce(Hash.new(0)) {|a,b| a[b] += 1;a}
    colors = rcell_mask.keys.count
    if (colors == 1) and (cell_mask[0] == @black ) then
      return 0
    end
    cell = img.get_pixels(px,py,8,8)
    rcell = cell.reduce(Hash.new(0)) {|a,b| a[b] += 1;a}

    acell = rcell.values.sort.reverse[2,64]
    bcell = acell != nil ? acell : [0]

    err = bcell.inject(0, &:+)
  end
end

result_file = "#{dir_best}/result.csv"
File.delete(result_file) if File.exist?(result_file)
rfile = File.open(result_file,"w")

best_file = "#{dir_best}/best.csv"
File.delete(best_file) if File.exist?(best_file)
bfile = File.open(best_file,"w")

e = Ev.new()

result = {}
dir_eval.each{|file|
  print "#{file}"
  begin
    file_mask = "#{dir_eval_mask}#{File.basename(file)}"

    if File.exist?(file_mask) then
      err = e.eval_image_with_mask(file,file_mask)
    else
      err = e.eval_image(file)
    end
    print ", #{err}\n"
    rfile.print "#{file}, #{err}\n"
    result[file] = err
  rescue RangeError => ex
    print " -> Error\n"
  end
}
sresult = result.sort_by {|k, v| v}.to_h

best = {}
worst = {}
sresult.each {|k,v|
  if best.count <=7
    best[k]=v
  end
  worst[:path] = k
  worst[:penalty] = v
  bfile.print "#{k}, #{v}\n"
}
print "Best: \n\n"
i = 0
best.each{|k,v|
  i = i + 1
  print "#{k} #{v}\n"
  FileUtils.copy(k,"./best/best_#{i}#{File.basename(k)}")
}
print "Worst: #{worst[:path]} #{worst[:penalty]}\n"

FileUtils.copy(worst[:path],"./best/worst_#{File.basename(worst[:path])}")