require 'json'

module ConfigParser

   class Parser

     # class responsible for parsing configs
     # and loading them into memory

     def max_amount_of_thread_members
       (@dct["maxThreadMemberNumber"] || 10).to_i
     end


     def mails_with_attachment_perc
       (@dct["mailsWithAttachmentPerc"] || 50).to_i
     end

     def maximum_attachment_size
       (@dct["maxAttachmentMegs"] || 20).to_i
     end

     def file_destination
       @dct["fileDestination"] || "./output"
     end

     def megs_per_inbox
       # 500 by default
       (@dct["megsPerInbox"] || 500).to_i
     end

     def number_of_inboxes
       # 500 by default
       (@dct["numberOfInboxes"] || 50).to_i
     end

     def rss_feeds
       @dct["rss"]
     end

     def remove_rss link
       @dct["rss"].delete(link)
     end

     def read_configs
       puts "configs: "
       @dct.each do |key, val|
         puts "#{key}: #{val}"
       end
     end

     private

     def initialize filename, filepath

       puts "reading Config File..."

       @filename = filename
       @filepath = filepath

       @dct = {}

       parse_config_file

       puts "Config File parsed..."

     end





     def parse_config_file
       @dct = parse_to_hash json_file
     end


     def parse_to_hash file
       JSON.parse(file)
     end


     def json_file
       File.read(@filepath  + @filename )
     end

   end

end
