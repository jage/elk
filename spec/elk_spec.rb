require 'spec_helper'
require 'elk'

describe Elk do
  it 'should detect missing username and/or password' do
    expect { Elk.base_url }.to raise_error(Elk::AuthError)

    Elk.configure do |config|
      config.username = nil
      config.password = 'PASSWORD'
    end

    expect { Elk.base_url }.to raise_error(Elk::AuthError)

    Elk.configure do |config|
      config.username = 'USERNAME'
      config.password = nil
    end

    expect { Elk.base_url }.to raise_error(Elk::AuthError)

    Elk.configure do |config|
      config.username = 'USERNAME'
      config.password = 'PASSWORD'
    end

    expect { Elk.base_url }.to_not raise_error(Elk::AuthError)
  end

  it 'should handle garbage json' do
    bad_response_body = fixture('bad_response_body.txt').read

    expect {
      Elk.parse_json(bad_response_body)
    }.to raise_error(Elk::BadResponse)
  end

  describe Elk::Number do
    it 'allocates a number' do
      stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers").
        with(:body => {"country" => "se", "sms_url" => "http://localhost/receive"},
             :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(fixture('allocates_a_number.txt'))

      configure_elk

      number = Elk::Number.allocate(:sms_url => 'http://localhost/receive', :country => 'se')
      number.status.should == :active
      number.sms_url.should == 'http://localhost/receive'
      number.country.should == 'se'
      number.number.should == '+46766861012'
      number.capabilities.should == [:sms]
    end

    it 'gets allocated numbers' do
      stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(fixture('gets_allocated_numbers.txt'))

      configure_elk

      numbers = Elk::Number.all
      numbers.size.should == 2
      numbers[0].number_id.should == 'nea19c8e291676fb7003fa1d63bba7899'
      numbers[0].number.should == '+46704508449'
      numbers[0].sms_url == 'http://localhost/receive1'

      numbers[1].number_id.should == 'nea19c8e291676fb7003fa1d63bba789A'
      numbers[1].number.should == '+46761042247'
      numbers[0].sms_url == 'http://localhost/receive2'
    end

    it 'updates a number' do
      stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(fixture('gets_allocated_numbers.txt'))
      stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers/nea19c8e291676fb7003fa1d63bba7899").
        with(:body => {"sms_url" => "http://otherhost/receive", "voice_start" => ""},
        :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(fixture('updates_a_number.txt'))

      configure_elk

      number = Elk::Number.all[0]
      number.country = 'no'
      number.sms_url = 'http://otherhost/receive'
      number.save.should == true
      number.country.should == 'no'
      number.sms_url.should == 'http://otherhost/receive'
    end

    it 'deallocates a number' do
      stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(fixture('gets_allocated_numbers.txt'))
      stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers/nea19c8e291676fb7003fa1d63bba7899").
        with(:body => {"active" => "no"},
        :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(fixture('deallocates_a_number.txt'))

      configure_elk

      number = Elk::Number.all[0]
      number.status.should == :active
      number.deallocate!.should == true
      number.status.should == :deallocated
    end

    it 'reloads a number' do
      stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(fixture('gets_allocated_numbers.txt'))
      stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers/nea19c8e291676fb7003fa1d63bba7899").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(fixture('reloads_a_number.txt'))

      configure_elk

      number = Elk::Number.all[0]
      object_id = number.object_id
      loaded_at = number.loaded_at
      number.country = 'blah'
      number.reload.should == true
      number.country.should == 'se'
      number.object_id.should == object_id
      number.loaded_at.should_not == loaded_at
    end

    it 'has wrong password' do
      stub_request(:get, "https://USERNAME:WRONG@api.46elks.com/a1/Numbers").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(fixture('auth_error.txt'))

      Elk.configure do |config|
        config.username = 'USERNAME'
        config.password = 'WRONG'
      end

      expect {
        Elk::Number.all
      }.to raise_error(Elk::AuthError)
    end

    it 'gets server error when looking for all numbers' do
      stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(fixture('server_error.txt'))

      configure_elk

      expect {
        Elk::Number.all
      }.to raise_error(Elk::ServerError)
    end

    it 'should handle no parameters' do
      configure_elk

      expect {
        sms = Elk::Number.allocate({})
      }.to raise_error(Elk::MissingParameter)
    end
  end

  describe Elk::SMS do
    it 'sends a SMS' do
      stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS").
        with(:body => {"from" => "+46761042247", :message => "Your order #171 has now been sent!", :to => "+46704508449"},
             :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(fixture('sends_a_sms.txt'))

      configure_elk

      # Fake $stderr to check warnings
      begin
        old_stderr, $stderr = $stderr, StringIO.new

        sms = Elk::SMS.send(:from => '+46761042247',
          :to => '+46704508449',
          :message => 'Your order #171 has now been sent!')

        $stderr.string.should == ""
      ensure
        $stderr = old_stderr
      end

      sms.class.should == Elk::SMS
      sms.from.should == '+46761042247'
      sms.to.should == '+46704508449'
      sms.message.should == 'Your order #171 has now been sent!'
      sms.direction.should == 'outgoing'
      sms.status.should == 'delivered'
    end

    it 'sends SMS to multiple recipients' do
      stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS").
        with(:body => {"from" => "+46761042247", :message => "Your order #171 has now been sent!", :to => "+46704508449,+46704508449"},
             :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(fixture('sends_a_sms_to_multiple_recipients.txt'))

      configure_elk
  
      smses = Elk::SMS.send(:from => '+46761042247',
        :to => '+46704508449,+46704508449',
        :message => 'Your order #171 has now been sent!')

      smses.size.should == 2
      smses[0].class.should == Elk::SMS
      smses[0].to.should == "+46704508449"

      smses[0].message_id.should == "sb326c7a214f9f4abc90a11bd36d6abc3"
      smses[1].message_id.should == "s47a89d6cc51d8db395d45ae7e16e86b7"
    end

    it 'gets SMS-history' do
      stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(fixture('sms_history.txt'))

      configure_elk

      sms_history = Elk::SMS.all

      sms_history.size.should == 3
      sms_history[0].class.should == Elk::SMS
      sms_history[0].created_at.class.should == Time

      sms_history[0].message.should == "Your order #171 has now been sent!"
      sms_history[1].message.should == "I'd like to order a pair of elks!"
      sms_history[2].message.should == "Want an elk?"
    end

    it 'reloads a SMS' do
      stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(fixture('sms_history.txt'))
      stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS/s8952031bb83bf3e64f8e13b071c131c0").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(fixture('reloads_a_sms.txt'))

      configure_elk

      sms_history = Elk::SMS.all
      sms = sms_history[0]
      loaded_at = sms.loaded_at
      object_id = sms.object_id
      sms.reload.should == true
      sms.object_id.should == object_id
      sms.loaded_at.should_not == loaded_at
    end

    it 'should warn about capped sms sender' do
      stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS").
        with(:body => {"from" => "VeryVeryVeryVeryLongSenderName", :message => "Your order #171 has now been sent!", :to => "+46704508449"},
             :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(fixture('sends_a_sms_with_long_sender.txt'))

      configure_elk

      # Fake $stderr to check warnings
      begin
        old_stderr, $stderr = $stderr, StringIO.new

        sms = Elk::SMS.send(:from => 'VeryVeryVeryVeryLongSenderName',
          :to => '+46704508449',
          :message => 'Your order #171 has now been sent!')

        $stderr.string.should == "SMS 'from' value VeryVeryVeryVeryLongSenderName will be capped at 11 chars\n"
      ensure
        $stderr = old_stderr
      end

      sms.class.should == Elk::SMS
      sms.from.should == 'VeryVeryVeryVeryLongSenderName'
      sms.to.should == '+46704508449'
      sms.message.should == 'Your order #171 has now been sent!'
    end

    it 'should handle invalid to number' do
      stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS").
        with(:body => {"from" => "+46761042247", :message => "Your order #171 has now been sent!", :to => "monkey"},
             :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(fixture('invalid_to_number.txt'))

      configure_elk

      expect {
        sms = Elk::SMS.send(:from => '+46761042247',
          :to => 'monkey',
          :message => 'Your order #171 has now been sent!')
      }.to raise_error(Elk::BadRequest, 'Invalid to number')
    end

    it 'should handle no parameters' do
      configure_elk

      expect {
        sms = Elk::SMS.send({})
      }.to raise_error(Elk::MissingParameter)
    end
  end
end