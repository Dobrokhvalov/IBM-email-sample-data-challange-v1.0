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

      incoming_messages.each do |message|
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




    def outgoing_messages
      #@messages.reject{|m| @incoming_messages.include? m }
      @messages.select{|m| not m.incoming? }
    end

    def incoming_messages
      @messages.select{|m| m.incoming? }
    end


    def build_email_tree

      change_subjects

      composer = Composer.new @messages, @account

      composer.compose

      composer.set_references_for_messages

      add_email_history

    end


    def set_message_ids
      @messages.map{|m| m.generate_message_id }
    end

    def unrelated_feeds?
      @messages.select{|m| m.subject.include? "Re:" or m.subject.include? "Answer by"}.empty?
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



  class Composer

    def choose_partner_without accounts
      participants_without(accounts).sample
    end

    def participants
      partners + [@account]
    end

    def participants_without accounts
      participants.reject{|p| accounts.include? p }
    end


    def compose
      # starting from the last message
      # (which is always incoming by default)
      # assign to message

      tmp_lst = @lst.clone
      prev_msg = tmp_lst.pop

      prev_partner = choose_partner_without [@account]
      receivers = participants_without [prev_partner]


      prev_msg.set_as_incoming_from prev_partner, receivers

      while tmp_lst.any?
        cur_msg = tmp_lst.pop

        partner = choose_partner_without [prev_partner]
        receivers = participants_without [partner]

        if partner == @account
          cur_msg.set_as_outgoing_to receivers
        else
          cur_msg.set_as_incoming_from partner, receivers
        end

        prev_msg.set_reply_msg_id cur_msg.generate_message_id
        prev_msg = cur_msg
        prev_partner = partner

      end
    end


    def set_references_for_messages
      ref_list = []
      @lst.each do |m|
        ref_list.map{ |m_id| m.add_reference(m_id) }
        ref_list << m.generate_message_id
      end
    end

    private

    def partners
      @partners ||= generate_partners
    end

    def generate_partners
      # randomly choose number of thread members
      #

      pool = (2..$config.max_amount_of_thread_members).to_a + [1] * $config.max_amount_of_thread_members
      n = pool.sample

      return n.times.map{|i| Account::Account.new }
    end

    def initialize messages, account
      @lst = messages.sort_by{|m| m.created_at }
      @account = account
    end

  end

end
