require 'spec_helper'
require 'elk'

describe Elk do
  describe Elk::Number do
    it 'allocates a number' do
      stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers").
        with(:body => "sms_url=http%3A%2F%2Flocalhost%2Freceive&country=se",
             :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(fixture('allocates_a_number.txt'))

      configure_elk

      number = Elk::Number.allocate(:sms_url => 'http://localhost/receive', :country => 'se')
      number.status.should == :active
      number.sms_url.should == 'http://localhost/receive'
      number.country.should == 'se'
      number.number.should == '+46766861012'
      number.capabilities == [:sms]
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
        with(:body => "country=no&sms_url=http%3A%2F%2Fotherhost%2Freceive",
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
        with(:body => "active=no",
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
      number.country = 'blah'
      number.reload
      number.country.should == 'se'
      number.object_id.should == object_id
    end
  end

  describe Elk::SMS do
    it 'sends a SMS' do
      stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS").
        with(:body => "from=%2B46761042247&to=%2B46704508449&message=Your%20order%20%23171%20has%20now%20been%20sent!",
             :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(fixture('sends_a_sms.txt'))

      configure_elk

      sms = Elk::SMS.send(:from => '+46761042247',
        :to => '+46704508449',
        :message => 'Your order #171 has now been sent!')
      #sms.status.should == Elk::SMS::Sent
    end

    it 'gets SMS-history' do
      stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(fixture('sms_history.txt'))

      configure_elk

      sms_history = Elk::SMS.all

      sms_history.size.should == 3
      sms_history[0].class.should == Elk::SMS
      sms_history[0].created_at.class.should == DateTime

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
  end
end