require 'fileutils'

in_filepath = ARGV[0]
rot_all     = ARGV[1].to_i
step_rot    = ARGV[2].to_i >= 1 ? ARGV[2].to_i : 1
scale_all   = ARGV[3].to_i
step_scale  = ARGV[4].to_i >= 1 ? ARGV[4].to_i : 1
offset      = ARGV[5].to_i || 1
mask        = ARGV[6].to_i || 0
#--------------------------------------------------------
in_filename = File.basename(in_filepath)
in_dir      = File.dirname(in_filepath)

in_maskname = "mask_#{in_filename}"
in_maskpath = "#{in_dir}/#{in_maskname}"

rot_from = -(rot_all / 2.0).round
rot_to   = (rot_all / 2).round

scale_from = (256)
scale_to   = (256+scale_all)
offset_range = offset == 1 ? -3..4 : 0..0

dir_evaluate = "./evaluate"
unless File.directory?(dir_evaluate)
  FileUtils.mkdir_p(dir_evaluate)
end
dir_best = "./best"
unless File.directory?(dir_best)
  FileUtils.mkdir_p(dir_best)
end
out_prefix = "#{dir_evaluate}/#{File.basename(in_filepath)}"
out_maskprefix = "#{dir_evaluate}/mask_#{File.basename(in_filepath)}"
out_ext    = ".png"

command_file = Gem.win_platform? ? "./run.bat" : "./run.sh"
File.delete(command_file) if File.exist?(command_file)
file = File.open(command_file,"w")

print "#{in_filepath}\n"

for rot in (rot_from..rot_to).step(step_rot)
  print "rotate #{rot}\n"
  for scale in (scale_from..scale_to).step(step_scale)
    print "    scale #{scale}\n"
    for offy in offset_range
      for offx in offset_range
        resize = "#{scale}x"
        tox = "%+d" % offx
        toy = "%+d" % offy

        out_file =  "#{out_prefix}_r#{rot}_s#{scale}_x#{offx}_y#{offy}#{out_ext}"
        out_mask =  "#{out_maskprefix}_r#{rot}_s#{scale}_x#{offx}_y#{offy}#{out_ext}"
        #print "         #{out_file}\n"
        #--------------------------------------------------------
        # in_file manipulation
        file.print "convert #{in_filepath} -gravity center -resize #{resize} -rotate #{rot} +repage -crop 256x192#{tox}#{toy} -gravity forget -extent 256x192#{tox}#{toy} #{out_file}\n"
        #file.print "convert #{in_filepath} -gravity center -resize #{resize} -rotate #{rot} +repage -crop 256x192#{tox}#{toy} #{out_file}c.png\n"
        #file.print "convert #{in_file} -gravity center -resize #{resize} -rotate #{rot} +repage -crop 256x192#{tox}#{toy} +dither -colors 8 #{out_file}\n"
        #file.print "convert #{in_file} -gravity center -resize #{resize} -rotate #{rot} +repage -crop 256x192#{tox}#{toy} -posterize 3 #{out_file}\n"
        #--------------------------------------------------------
        # in_mask manipulation
        if mask != 0 then
          file.print "convert #{in_maskpath} -gravity center -resize #{resize} -rotate #{rot} +repage -crop 256x192#{tox}#{toy} -monochrome #{out_mask}\n"
        end
      end
    end
  end
end

#`sh #{command_file}`