require 'modules/message'

module Conversation
  class Thread

    def add subject, sent_at, text


      message = Message::Message.new subject, sent_at, text, @account

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


    def add_email_history_for_html

      @messages.each_with_index do |m, i|

        text_to_add_html = "<br><br>On #{m.created_at}, #{m.account_from.print_for_html} wrote: <blockquote>" + m.html_part

        m.html_part += @history_html + "</blockquote>" * i

        @history_html =  text_to_add_html + @history_html

      end

    end

    def add_email_history_for_plain_text

      @messages.each_with_index do |m, i|


        text_to_add = "\n\nOn #{m.created_at}, #{m.account_from} wrote:\n" +  ("\n" + m.text_part).gsub("\n", "\n>")

        m.text_part += @history_text

        @history_text =  text_to_add + @history_text

        # adding '>' for plain text in history
        @history_text.gsub!("\n", "\n>")
      end

    end

    def add_email_history

      add_email_history_for_plain_text

      add_email_history_for_html

    end


    def change_subjects
      @messages.each_with_index do |m,i|

        # changing subject only for
        if m != starting_message
          m.subject = "Re: " + starting_message.subject
        end
      end
    end

    def select_incoming_messages

      @messages.odd_values.each do |m|
        @incoming_messages << m
      end

    end


    

    def set_email_from_for_outgoing_messages
      # all messages that not incoming are outgoing
      outgoing_messages.each do |m|
        m.account_from = @account
      end
    end

    def set_email_from_for_incoming_messages

      partner = Account::Account.new

      # all messages that not incoming are outgoing
      @incoming_messages.each do |m|
        m.account_from =  partner
      end
    end


    def outgoing_messages
      @messages.reject{|m| @incoming_messages.include? m }
    end


    def build_email_tree
      
      change_subjects
      
      select_incoming_messages

      set_email_from_for_incoming_messages

      set_email_from_for_outgoing_messages

      # for reply-to and references
      generate_message_ids

      #add_message_references
      
      add_email_history
      
    end

    #def add_message_references
    #  @messages.each do |m|
    #    
    #  end
    #end
    
    def set_message_ids
      @messages.map{|m| m.generate_message_id }
    end
    
    def unrelated_feeds?
      @messages.select{|m| m.subject.include? "Re:" or m.subject.include? "Answer by"}.empty? #and participants.count > 1
    end

    def starting_message
      @start ||= @messages.reject{|m| m.subject.include? "Re:" or m.subject.include? "Answer by"}.first
    end

    def all_messages_are_incoming
      @messages.each do |m|
        @incoming_messages << m
      end
    end



    def initialize account
      @incoming_messages = []
      
      @messages = []
      
      
      @account = account
      
      @history_text = ""
      @history_html = ""

    end




  end


end
