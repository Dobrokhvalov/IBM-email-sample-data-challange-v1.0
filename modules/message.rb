require 'nokogiri'
require 'mail'
require 'uuid'
require 'modules/helper'
require 'fileutils'

module Message
  class Message

    attr_reader  :created_at, :message_id
    attr_accessor :html_part, :text_part, :subject, :account_from, :account_to

    @@count = 0

    def generate_message_id
      #@message_id = SecureRandom.hex(32)
      @message_id ||= "<#{ UUID.generate }@#{@account_from.domain}>"
    end

    def set_as_incoming_from account, recipients
      @incoming = true
      @account_from = account

      @recipients = recipients

    end

    def set_as_outgoing_to recipients
      @incoming = false
      @account_from = @account_to
      @recipients = recipients

    end



    def write_eml

      title = @subject
      text = @text
      send_at = @created_at
      attached_file_flag = false
      dummy_filename = nil
      recipients = @recipients.map{|r| r.email }
      account_from = @account_from
      account = @account
      custom_message_id = generate_message_id

      mail = Mail.new do
        date send_at
        to      recipients
        from    account_from
        subject title
        message_id custom_message_id

        # creating dummy file to attach

        # 50% chance to for adding file if we need space to full
        if not account.folder_full? and [true, false].sample
          attached_file_flag = true

          # randomly choose megs from 1 to 20 (by default)
          n = (1..$config.maximum_attachment_size).to_a.sample


          dummy_path = "./tmp"
          FileUtils::mkdir_p(dummy_path)

          dummy_filename = "#{dummy_path}/file-#{n}M.txt"

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
      mail.html_part = html_part



      eml_content = compose_eml mail

      filename = sanitize_filename(@message_id)

      File.open("./#{@account_to.inbox_path}/#{filename}.eml", 'w') { |file| file.write(eml_content) }

      # erasing dummy file
      if attached_file_flag
       File.delete(dummy_filename)
      end

    end

    def compose_eml mail
      content = mail.to_s

      if not @references.empty?

        refs_part = "References: #{@references}"
        content = refs_part + content
      end


      if not @reply_msg_id.nil?
        reply_to_part = "In-Reply-To: #{@reply_msg_id}\n"
        content = reply_to_part + content
      end


      return content


    end

    def incoming?
      @incoming
    end

    def set_reply_msg_id msg_id
      @reply_msg_id = msg_id
    end

    def add_reference msg_id
      @references += "#{msg_id}\n"
    end

    private

    def initialize subject, created_at, text, account
      @@count += 1

      @count = @@count
      @subject = subject
      @created_at = created_at
      @text = text

      @account = account

      @account_from = Account::Account.new
      @account_to = account

      @recipients = [account_to ]

      @html_part = CGI.unescapeHTML(text)
      @text_part = Nokogiri::HTML(@html_part).content

      @incoming = true

      @reply_msg_id = nil

      @references = ""
    end

  end



end
