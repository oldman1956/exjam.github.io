# ImageSet Liquid Plugin
# by Erik Dungan
# erik.dungan@gmail.com / @callmeed
# 
# Takes a dir, gets all the images from it, and creates HTML image and container tags
# Useful for creating an image gallery and the like 
# 
# USAGE
# default: {% image_set images/gallery1 %}
# (this will create a UL, then LI and IMG tags for each image in images/gallery1)
# 
# with options: {% image_set images/gallery2 --class=img-responsive --container-tag=div --wrap-tag=div %}
# (this will set the class for the <img> tags and use <div>s for the container and wrap)
# 
# OPTIONS
# --class=some_class (sets the class for the <img> tags, default is 'image')
# --wrap_tag=some_tag (sets the tag to wrap around each <img>, default is 'li')
# --wrap_class=some_class (sets the class for wrap_tag, default is 'image-item')
# --container_tag=some_tag (sets the tag to contain all <img>s, default is 'ul')
# --container_class=some_class (sets the class for container_tag, default is 'image-set')

require 'mini_magick'

module Jekyll
  class ImageSet < Liquid::Tag
    def initialize(tag_name, text, tokens)
      super
    end

    def render(context)
      config  = context.registers[:site].config['puush_gallery']
      gallery_dir = File.join(context.registers[:site].config['source'], config['dir'])
      source = "<div id='puush_gallery'>"

      Dir.glob(File.join(gallery_dir, "**", "*.{png,jpg,jpeg,gif}")).each do |file|
          name = File.basename(file)
          match = /.*(\d{4}-\d{2}-\d{2}).*(\d{2}.\d{2}.\d{2}).*/.match(name)
          name = match[1] + '_' + match[2]
          orig_name = name + File.extname(file)
          thumb_name = name + '_320' + File.extname(file)

          img = MiniMagick::Image.open(file)
          longestSide = img.height
          width = 320.0 * img.width.to_f / longestSide
          height = 320.0 * img.height.to_f / longestSide

          source += "<a href='/thumbs/#{orig_name}' title='<b>#{match[1]}</b><br />testing a long description and title about the image which lets people know what is happening'>"
          source += "<img src='/thumbs/#{thumb_name}' width='#{width.to_i}' height='#{height.to_i}' />"
          source += "</a>"
      end

      source += "</div>"
      return source
    end
  end

  class ThumbGenerator < Generator
    def generate(site)
      @config = site.config['puush_gallery']
      @gallery_dir  = File.expand_path(@config['dir'])
      @gallery_dest = File.expand_path(File.join(site.dest, @config['dir']))

      @long_sides = [
        #{"suffix" => '_100', "size" => 100.0 },
        #{"suffix" => '_240', "size" => 240.0 },
        {"suffix" => '_320', "size" => 320.0 },
        #{"suffix" => '_500', "size" => 500.0 },
        #{"suffix" => '_640', "size" => 640.0 },
        #{"suffix" => '_1024', "size" => 1024.0 },
      ]

      thumbify(files_to_resize(site))
    end

    def files_to_resize(site)
      to_resize = []
      gallery_dir = File.join(site.config['source'], @gallery_dir)

      FileUtils.mkpath('thumbs')

      Dir.glob(File.join(gallery_dir, "**", "*.{png,jpg,jpeg,gif}")).each do |file|
        @long_sides.each do |long_side|
          name = File.basename(file)
          match = /.*(\d{4}-\d{2}-\d{2}).*(\d{2}.\d{2}.\d{2}).*/.match(name)
          name = match[1] + '_' + match[2]
          orig_name = name + File.extname(file)
          thumb_name = name + long_side['suffix'] + File.extname(file)
          orig_file = File.join('thumbs', orig_name)
          thumb_file = File.join('thumbs', thumb_name)

          site.static_files << Jekyll::StaticFile.new(site, site.source, 'thumbs', orig_name)
          site.static_files << Jekyll::StaticFile.new(site, site.source, 'thumbs', thumb_name)

          if not File.exist?(orig_file)
            FileUtils.copy(file, orig_file)
          end

          if not File.exist?(thumb_file)
            to_resize.push({
              "file" => file,
              "thumbname" => thumb_file,
              "size" => long_side['size']
              })
          end
        end
      end

      return to_resize
    end

    def thumbify(items)
      if items.count > 0
        items.each do |item|
          img = MiniMagick::Image.open(item['file'])
          longestSide = img.height
          width = img.width.to_f / longestSide
          height = img.height.to_f / longestSide
          width = width * item['size']
          height = height * item['size']
          img.resize "#{width.to_i}x#{height.to_i}"
          img.write(item['thumbname'])
        end
      end
    end

  end
end

Liquid::Template.register_tag('puush_gallery', Jekyll::ImageSet)
