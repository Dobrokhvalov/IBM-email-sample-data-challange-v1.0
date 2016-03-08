require 'faker'
require 'fileutils'
require 'modules/helper'

module Account
  class Account

    attr_reader :name, :email

    def to_s
      "#{@name} <#{@email}>"
    end

    def print_for_html
      @name + ' &lt;<a href=' + 'mail_to:"' + @email + '" target="_blank">'  + @email + '</a>&gt;'
    end

    def create_inbox_folder path
      FileUtils::mkdir_p inbox_path(path)
    end

    def inbox_path path = nil
      @inbox_path ||= "#{path}/#{@email}"
    end

    def domain
      @email.split("@").last
    end

    def set_folder_size megs
      @bytes_needed = megs * 1024 * 1024
    end

    def folder_full?
      current_folder_size >= @bytes_needed
    end

    # def folder_full_with? megs
    #   current_folder_size + (megs * 1024 * 1024) >= @bytes_needed
    # end

    # def bytes_needed
    #    @bytes_needed - current_folder_size
    # end


    private

    def current_folder_size
      directory_size(@inbox_path)
    end

    def initialize
      @inbox_path = nil
      @name = Faker::Name.name
      @email = Faker::Internet.email

      @bytes_needed = 0
    end


  end


end
