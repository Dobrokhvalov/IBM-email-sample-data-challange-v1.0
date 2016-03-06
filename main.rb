$LOAD_PATH << '.'

require 'modules/config_parser'
require 'modules/rss_handle'
require 'modules/output'


def main

  # name of config file
  config_filename = "config.json"

  # path to config
  config_path = "./"

  puts ""
  puts "-" * 10
  puts "START"
  puts ""



  # parsing config
  config_parser = ConfigParser::Parser.new(config_filename, config_path)


  # generating email data for needed amount of accounts

  #config_parser.number_of_inboxes.times.each do |i|
  #  puts "generating .eml files for user ##{i}"
  #  end
  #config_parser.rss_feeds.each do |link|
  #  rss_getter = RSSHandle::Getter.new link #"http://stackoverflow.com/feeds" #"http://stackoverflow.com/feeds/question/35741275"
  #end

  rss_getter = RSSHandle::Getter.new  "http://apps.topcoder.com/forums/?module=RSS&threadID=874783"
  #byebug





  puts ""
  puts "FINISH"
  puts "-" * 10
  puts ""




end




# runnig the script
main
