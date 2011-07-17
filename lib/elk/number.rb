module Elk
  class Number
    attr_reader :number_id, :number, :capabilities, :loaded_at
    attr_accessor :country, :sms_url

    def initialize(parameters)
      set_paramaters(parameters)
    end

    def set_paramaters(parameters)
      @country = parameters[:country]
      @sms_url = parameters[:sms_url]
      @status  = parameters[:active]
      @number_id  = parameters[:id]
      @number = parameters[:number]
      @capabilities = parameters[:capabilities].collect {|c| c.to_sym }
      @loaded_at = Time.now
    end

    def status
      case @status
      when 'yes'
        :active
      when 'no'
        :deallocated
      else
        nil
      end
    end

    def reload
      response = Elk.get("/Numbers/#{self.number_id}")

      self.set_paramaters(JSON.parse(response.body, :symbolize_names => true))

      response.code == 200
    end

    def save
      response = Elk.post("/Numbers/#{self.number_id}", {:country => self.country, :sms_url => self.sms_url})

      response.code == 200
    end

    def deallocate!
      response = Elk.post("/Numbers/#{self.number_id}", {:active => 'no'})

      @status = 'no'

      response.code == 200
    end

    class << self
      def allocate(parameters)
        response = Elk.post('/Numbers', parameters)

        self.new(JSON.parse(response.body, :symbolize_names => true))
      end

      def all
        response = Elk.get('/Numbers')

        JSON.parse(response.body, :symbolize_names => true)[:numbers].collect do |n|
          self.new(n)
        end
      end
    end
  end
end