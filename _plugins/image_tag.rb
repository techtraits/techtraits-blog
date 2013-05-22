# Image Tag
#
# Easily put an image into a Jekyll page or blog post and add image meta data
#
# Format:
# {% image URL|PATH [class=""] [style=""] %}
#
# Examples:
#   Input:
#     {% image http://path/to/image.png %}
#   Output:
#      <figure>
#        <img src='http://path/to/image.png'>
#      </figure>
#
#   Input:
#     {% image http://path/to/image.png class="full" %}
#   Output:
#      <figure class='full'>
#        <img src="http://path/to/image.png">
#      </figure>
#
#   Input:
#     {% image http://path/to/image.png style="float:left" %}
#   Output:
#      <figure>
#        <img src="http://path/to/image.png" style="float:left">
#      </figure>
#
#   Input:
#     {% image http://path/to/image.png class="full" style="float:left" %}
#   Output:
#      <figure class='full'>
#        <img src="http://path/to/image.png" style="float:left">
#      </figure>
#
#
module Jekyll
  class ImageTag < Liquid::Tag
    @url = nil
    @class = nil
    @style = nil
    @alt= nil

	IMAGE_URL = /((https?:\/\/|\/)(\S+))/i
    IMAGE_CLASS = /class=\"(\S+)\"/i
    IMAGE_STYLE = /style=\"(\S+)\"/i
    IMAGE_ALT = /alt=\"(\S+[\S+\s+]+\S+)\"/i

    def initialize(tag_name, markup, tokens)
      super

      if markup =~ IMAGE_URL
      	@url = "\"#{$1}\""
      end
      
      if markup =~ IMAGE_CLASS
        @class   = "class='#{$1}'"
      end
   
      if markup =~ IMAGE_STYLE
        @style   = "style=\"#{$1}\""
      end
      
	  if markup =~ IMAGE_ALT
        @alt   = "alt=\"#{$1}\""
      end
     
    end

    def render(context)
      source = "<img src=#{@url} #{@style} #{@alt}>"
    end
  end
end

Liquid::Template.register_tag('image', Jekyll::ImageTag)