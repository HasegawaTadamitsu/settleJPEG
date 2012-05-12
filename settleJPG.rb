# -*- coding: utf-8 -*-
require "optparse"
require 'exifr'
require 'fileutils'
#require "pry"

@option = Hash.new
opts = OptionParser.new
opts.on '-s f','--source','source directory' do |v|
  @option[:src_dir] = v
end

opts.on '-d f','--dest','dest directory' do |v|
  @option[:dest_dir] = v
end

if ARGV[0].nil?
  puts "need argment:"
  puts opts.help
  exit 1
end

begin
  opts.parse!(ARGV)
rescue =>ex
  puts ex
  puts opts.help
  exit 1
end

if @option[:src_dir].nil?
  puts "need source directory option."
  puts opts.help
  exit 1
end

if @option[:dest_dir].nil?
  puts "need dest directory option."
  puts opts.help
  exit 1
end


def createJPGList dir
  # Dir::entries dir ←すべてのファイル
  ret =Array.new
  Dir::glob( dir + "/**/*.[jJ][pP][gG]" ).each do |f|
   ret.push  f
  end
  Dir::glob( dir + "/**/*.[jJ][pP][eE][gG]" ).each do |f|
   ret.push  f
  end
 return ret
end


def imageDate file
  begin
    exifr = EXIFR::JPEG.new(file).exif
    return exifr.date_time
  rescue 
    # jpegでない場合や、日付が取得できない場合nill
    return nil
  end
end


def create_directory basedir, datetime
  if datetime.nil? 
    name = "unknown"
  else
    name = datetime.strftime("%Y%m%d")
  end
  dirname =  basedir + "/" + name
  if FileTest::directory? dirname
    return dirname
  end
  Dir::mkdir dirname
  return dirname
end

def copy fromImage, dest_dir
  toFile = dest_dir + "/" + File::basename( fromImage )
  if FileTest.exists? toFile
    puts "already exist file. #{fromImage} #{toFile}"
    return
  end
  FileUtils.cp( fromImage, dest_dir, {:preserve=>true})
end

files = createJPGList @option[:src_dir]
files.each do |imageFile|
  datetime = imageDate imageFile
  dest_dir = create_directory @option[:dest_dir], datetime
  copy imageFile, dest_dir
end

