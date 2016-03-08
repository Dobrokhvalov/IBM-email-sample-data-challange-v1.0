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
  config = ConfigParser::Parser.new(config_filename, config_path)


  sources_list = []

  # generating email data for needed amount of accounts
  config.number_of_inboxes.times.each do |i|

    account  = Account::Account.new

    puts "generating .eml files for user ##{i}: #{account}"
    account.create_inbox_folder config.file_destination

    account.set_folder_size config.megs_per_inbox


    while true do

      # stopping only when acount is full
      if account.folder_full?
        break
      end

      # repeating RSS Feeds if needed
      if sources_list.empty?
        sources_list = config.rss_feeds.shuffle.clone

        # when no RSS feeds in config
        if sources_list.empty?
          abort("\nPut list of RSS in config.json file!")
        end
      end

      link = sources_list.pop

      begin
        rss_getter = RSSHandle::Getter.new link

        feeds = rss_getter.get_feeds

        thread = Conversation::Thread.new account

        feeds.each do |feed|
          thread.add feed.subject, feed.sent_at, feed.text
        end

        thread.build

        thread.write_emls
      rescue Exception => e
        puts "ERROR! problem with RSS Feed: '#{link}'. Removing it from RSS list"
        puts e.message
        #puts e.backtrace.inspect
        config.remove_rss link
      end

    end

  end













  puts ""
  puts "FINISH"
  puts "-" * 10
  puts ""




end




# runnig the script
main
