require 'faker'

module Account
  class Account

    attr_reader :name, :email

    def to_s
      "#{@name} <#{@email}>"
    end

    def print_for_html
      @name + ' &lt;<a href=' + 'mail_to:"' + @email + '" target="_blank">'  + @email + '</a>&gt;'
    end

    private

    def initialize
      @name = Faker::Name.name
      @email = Faker::Internet.email
    end


  end


end
