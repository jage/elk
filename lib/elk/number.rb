module Elk
  class Number
    attr_reader :number_id, :number, :capabilities, :loaded_at
    attr_accessor :country, :sms_url

    def initialize(parameters)
      set_paramaters(parameters)
    end

    def set_paramaters(parameters)
      @country      = parameters[:country]
      @sms_url      = parameters[:sms_url]
      @status       = parameters[:active]
      @number_id    = parameters[:id]
      @number       = parameters[:number]
      @capabilities = parameters[:capabilities].collect {|c| c.to_sym }
      @loaded_at    = Time.now
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
      self.set_paramaters(Elk.parse_json(response.body))
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
        parameters.require_keys!([:sms_url, :country])
        response = Elk.post('/Numbers', parameters)
        self.new(Elk.parse_json(response.body))
      end

      def all
        response = Elk.get('/Numbers')

        Elk.parse_json(response.body)[:numbers].collect do |n|
          self.new(n)
        end
      end
    end
  end
end