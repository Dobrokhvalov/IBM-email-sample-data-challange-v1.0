require 'simple-rss'
require 'open-uri'



module RSSHandle


  class Getter
    attr_reader :feeds
    # class in charge of getting the RSS feeds

    def get_feeds
      rss.feed.items.each do |item|
        feed = FeedHandler.new item
        @feeds << feed
      end

      return @feeds
    end

    private


    def initialize url

      puts "getting feeds from: #{url}"

      @feeds = []

      @url = url


    end



    def rss
      @rss ||= SimpleRSS.parse open(@url)
    end



  end


  class FeedHandler

    # class for handling different RSS structure
    # e.g "published" vs "pubDate"

    def subject
      @item.title
    end

    def sent_at
      @item.published || @item.pubDate
    end

    def text
      @item.summary || @item.description
    end


    private

    def initialize item
      @item = item
    end
  end



end
