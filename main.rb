$LOAD_PATH << '.'

require 'modules/config_parser'
require 'modules/rss_handle'
require 'modules/account'
require 'modules/conversation'

# name of config file
config_filename = "config.json"

# path to config
config_path = "./"

# parsing config
# global variable to use in other modules
$config = ConfigParser::Parser.new(config_filename, config_path)


def main
  puts ""
  puts "-" * 10
  puts "START"
  puts ""
  sources_list = []

  # generating email data for needed amount of accounts
  $config.number_of_inboxes.times.each do |i|

    account  = Account::Account.new

    puts "generating .eml files for user ##{i+1}: #{account}"
    account.create_inbox_folder $config.file_destination

    account.set_folder_size $config.megs_per_inbox


    while true do

      # stopping only when acount is full
      if account.folder_full?
        break
      end

      # repeating RSS Feeds if needed
      if sources_list.empty?
        sources_list = $config.rss_feeds.shuffle.clone

        # when no RSS feeds in config
        if sources_list.empty?
          abort("\nPut list of RSS in $config.json file!")
        end
      end

      # next RSS Feed link
      link = sources_list.pop


      begin

        # getting feeds from RSS link
        rss_getter = RSSHandle::Getter.new link
        feeds = rss_getter.get_feeds


        # building discussion thread
        thread = Conversation::Thread.new account
        feeds.each do |feed|
          thread.add feed.subject, feed.sent_at, feed.text
        end
        thread.build

        # writing .eml files
        thread.write_emls

      rescue Exception => e
        puts "ERROR! problem with RSS Feed: '#{link}'. Removing it from RSS list"
        puts e.message

        # removing broken link from sources
        $config.remove_rss link
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
