$LOAD_PATH << '.'

require 'modules/config_parser'
require 'modules/rss_handle'
require 'modules/account'
require 'modules/conversation'



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
  account  = Account::Account.new

  #config_parser.rss_feeds.each do |link|
  #  rss_getter = RSSHandle::Getter.new link, account #"http://stackoverflow.com/feeds" #
  #end


  rss_getter = RSSHandle::Getter.new "http://apps.topcoder.com/forums/?module=RSS&threadID=874783"

  feeds = rss_getter.get_feeds

  thread = Conversation::Thread.new account

  feeds.each do |feed|
    thread.add feed.subject, feed.sent_at, feed.text
  end

  thread.build

  thread.write_emls





  puts ""
  puts "FINISH"
  puts "-" * 10
  puts ""




end




# runnig the script
main
