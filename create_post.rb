#!/usr/bin/env ruby

# Script to create a blog post using a template. It takes one input parameter
# which is the title of the blog post
# e.g. command:
# $ ./create_post.rb "helper script to create new posts using jekyll"
#
# Author:Usman Ismail

# Some constants
TEMPLATE = "_template.markdown"
TARGET_DIR = "_posts"

# Check Argument count
if ARGV.length != 4
	abort "Usage: create_post.rb TITLE AUTHOR CATEGORY_1,CATEGORY_2 TAG_1,TAG_2"
end
	
# Get the title which was passed as an argument
title = ARGV[0]
author = ARGV[1]
categories = ARGV[2].dup
categories.gsub!(',', "\n- ");
tags = ARGV[3].dup
tags.gsub!(',', "\n- ");

# Get the filename and remove some unsupported characters
# TODO probably need to make list of disallowed characters more complete 
filename = title.gsub(' ','-')
filename = filename.gsub(':','-')
filename = filename.gsub(';','-')

filename = "#{ Time.now.strftime('%Y-%m-%d') }-#{filename}.markdown" 
filepath = File.join(TARGET_DIR, filename)

# Create a copy of the template with the title replaced
new_post = File.read(TEMPLATE)
new_post.gsub!('TITLE', title);
new_post.gsub!('DATE', "#{ Time.now.strftime('%Y-%m-%d %H:%M:%S') }");
new_post.gsub!('AUTHOR', author);
new_post.gsub!('CATEGORIES', categories);
new_post.gsub!('TAGS', tags);

# Write out the file to the target directory
new_post_file = File.open(filepath, 'w')
new_post_file.puts new_post
new_post_file.close

puts "created => #{filepath}"