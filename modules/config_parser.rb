require 'json'

module ConfigParser

   class Parser


     def file_destination
       @dct["fileDestination"]
     end

     def megs_per_inbox
       (@dct["megsPerInbox"] || 500).to_i
     end

     def number_of_inboxes
       @dct["numberOfInboxes"].to_i
     end

     def rss_feeds
       @dct["rss"]
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
