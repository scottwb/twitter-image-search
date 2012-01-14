#!/usr/bin/env ruby

require 'twitter'
require 'open-uri'

# Max number of requests for another page of tweets.
MAX_PAGES  = 15

# Max number of images to get (approximate). We just stop if we have at
# least this many.
MAX_IMAGES = 50

# Given a tweet, extract an array hashes that describe the embedded images.
# Only pulls out the URLs to large images.
# This hash is in the form:
#
#    {
#      :url => the URL to the tweet,
#      :created_at => A Time object describin when the image was posted
#    }
#
def extract_images(tweet)
  image_urls = []
  (tweet.attrs['entities']['media'] || []).each do |media|
    if (media['type'] == 'photo') && media['sizes'].include?('large')
      image_urls << "#{media['media_url']}:large"
    end
  end

  image_urls.map do |url|
    {
      :url        => url,
      :created_at => tweet.created_at
    }
  end
end

# Query for recent images tweeted that match the given query.
#
# Options: See 'default_options' below.
#
# Returns: Array of image hashes as described by extract_images above.
def query_for_images(query, options = {})
  default_options = {
    # Approx limit to the number of images we care to get.
    :limit     => 50,

    # Max number of requests for pages of tweets
    :max_pages => 15,
  }
  all_images = []

  page = 1
  MAX_PAGES.times do
    puts "Querying for 100 tweets matching '#{query}'..."
    tweets = Twitter.search(
      query,
      :rpp              => 100,
      :page             => page,
      :include_entities => true
    )
    images = tweets.map{|t| extract_images(t)}.flatten
    puts "  Got #{images.size} images."
    all_images += images
    
    # Quit if there aren't any matching tweets.
    break if tweets.empty?

    # Jump to next page. Quit if we hit the limit.
    page += 1
    break if page > MAX_PAGES
    
    # Quit if we got enough images
    break if all_images.size > MAX_IMAGES
  end

  uniq_images = {}
  all_images.each do |image|
    if !uniq_images.include?(image[:url])
      uniq_images[image[:url]] = image
    end
  end
  uniq_images.values.sort_by{|image| image[:created_at]}
end

# Given an image hash (see extract_images), download it into the specified
# directory and save it with a file named for its created_at timestamp.
def download_image(image, dir)
  ext      = image[:url][/^.*\.(.{3}):large$/, 1]
  filename = "#{dir}/#{image[:created_at].utc.strftime('%Y%m%d%H%M%S')}.#{ext}"
  if File.exists?(filename)
    puts "    File already exists: #{filename}"
  else
    puts "    Downloading: #{filename}"
    File.open(filename, "wb") do |f|
      f.write(open(image[:url]).read)
    end
  end
end


############################################################
# Main Program
############################################################

# Concat all cmdline params as the query string.
query  = ARGV.join(' ')

# Make a sanitized dir to hold downloaded images.
dir    = query.downcase.gsub(/[^a-z0-9]+/, '-')
Dir.mkdir(dir) if !Dir.exist?(dir)

# Query for the images and download them.
images = query_for_images(query)
images.each{|i| download_image(i, dir)}

# Gimme a quick summary.
puts
puts "Got a total of #{images.size} images:"
images.each do |image|
  puts "    [#{image[:created_at].strftime('%Y-%m-%d %H:%M:%S')}] #{image[:url]}"
end
puts
