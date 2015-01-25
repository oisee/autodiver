
require 'fileutils'

in_file    = ARGV[0]
rot_all    = ARGV[1].to_i
step_rot   = ARGV[2].to_i || 1
scale_all  = ARGV[3].to_i
step_scale = ARGV[4].to_i || 1
offset     = ARGV[5].to_i || 1

rot_from = -(rot_all / 2.0).round
rot_to   = (rot_all / 2).round

scale_from = (256)
scale_to   = (256+scale_all)
offset_range = offset == 1 ? -3..4 : 0..0

dirname = "./evaluate"
unless File.directory?(dirname)
  FileUtils.mkdir_p(dirname)
end
out_prefix = "#{dirname}/out"
out_ext    = ".png"

command_file = "./run.sh"
File.delete(command_file) if File.exist?(command_file)
file = File.open(command_file,"w")

print "#{in_file}\n"

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
        #print "         #{out_file}\n"

        file.print "convert #{in_file} -gravity center -resize #{resize} -rotate #{rot} +repage -crop 256x192#{tox}#{toy} #{out_file}\n"
        #file.print "convert #{in_file} -gravity center -resize #{resize} -rotate #{rot} +repage -crop 256x192#{tox}#{toy} +dither -colors 8 #{out_file}\n"
        #file.print "convert #{in_file} -gravity center -resize #{resize} -rotate #{rot} +repage -crop 256x192#{tox}#{toy} -posterize 3 #{out_file}\n"

      end
    end
  end
end

#`sh #{command_file}`