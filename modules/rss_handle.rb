require 'simple-rss'
require 'open-uri'
require 'mail'
require 'nokogiri'

module RSSHandle

  class Getter
    attr_reader :thread
    # class in charge of getting the RSS feeds


    private


    def initialize url
      puts "getting feeds from: #{url}"

      @url = url

      @thread = Thread.new rss.feed.title


      # first adding feeds
      rss.feed.items.each do |item|
        @thread.add item
      end

      @thread.build

      @thread.write_emls



    end

    def rss
      @rss ||= SimpleRSS.parse open(@url)
    end



  end


  class FeedHandler

    def subject
      @item.title
    end

    def sent_at
      @item.published || @item.pubDate
    end

    def text
      @item.summary || @item.description
    end

    def user
      @item.dc_creator || @item.author
    end

    private

    def initialize item
      @item = item
    end
  end

  class Thread

    def add item

      feed = FeedHandler.new item
      message = Message.new feed.subject, feed.sent_at, feed.text, feed.user

      @messages << message

    end


    def build

      @messages = @messages.sort_by{|m| m.created_at }

      if unrelated_feeds?
        all_messages_are_incoming
      else
        build_email_tree
      end
    end

    def write_emls
      @incoming_messages.each do |message|
        message.write_eml
      end
    end


    private

    def participants
      @uniq_users ||=  @messages.map{|m| m.user }.uniq
    end

    def build_email_tree
      # choosing current user randomly
      #@current_user = participants.sample

      @current_user = participants.first

      # selecting incoming messages
      @messages.each do |m|
        if m.user != @current_user
          @incoming_messages << m
        end
      end


      @messages.each do |m|


        m.text_part += @history_text

        text_to_add = "\n\nOn #{m.created_at}, #{m.user} wrote:\n" +  ("\n" + m.text_part).gsub("\n", "\n>")

        @history_text +=  text_to_add



      end



    end

    def unrelated_feeds?
      @messages.select{|m| m.subject.include? "Re:" or m.subject.include? "Answer by"}.empty? and participants.count > 1
    end

    def all_messages_are_incoming
      @messages.each do |m|
        @incoming_messages << m
      end
    end





    def initialize subject
      @incoming_messages = []
      @subject = subject
      @messages = []
      @users = []

      @history_text = ""
    end




  end


  class Message

    attr_reader :subject, :created_at, :user
    attr_accessor :html_part, :text_part

    @@count = 0

    def write_eml

      title = @subject
      text = @text
      send_at = @created_at



      attached_file_flag = false

      dummy_filename = nil

      mail = Mail.new do
        date send_at
        to      'nicolas@test.lindsaar.net.au'
        from    'Mikel Lindsaar <mikel@test.lindsaar.net.au>'
        subject title



        # creating dummy file to attach
        if @@count == 1
          attached_file_flag = true

          n = 1
          dummy_filename = "./file-#{n}M.txt"
          f = File.open(dummy_filename, "w") do |f|
            contents = "x" * (1024*1024)
            n.to_i.times { f.write(contents) }
          end

          add_file dummy_filename


        end


      end

      message_txt = @text_part

      text_html = @html_part

      text_part = Mail::Part.new do

        body message_txt
      end

      html_part = Mail::Part.new do
        content_type 'text/html; charset=UTF-8'
        body text_html
      end


      mail.text_part = text_part
      #mail.html_part = html_part




      File.open("./output/#{@count}.eml", 'w') { |file| file.write(mail.to_s) }

      # erasing dummy file
      if attached_file_flag
        File.delete(dummy_filename)
      end

    end




    private

    def initialize subject, created_at, text, user
      @@count += 1

      @count = @@count
      @subject = subject
      @created_at = created_at
      @text = text
      @user = user

      @html_part = CGI.unescapeHTML(text)
      @text_part = Nokogiri::HTML(@html_part).content



    end




  end


end
