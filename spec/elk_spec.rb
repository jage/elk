require 'spec_helper'
require 'elk'

describe Elk do
  describe Elk::Account do
    it 'initiates an account' do
      elk = Elk::Account.new(:username => 'USERNAME', :password => 'PASSWORD')
      elk.username.should == 'USERNAME'
      elk.password.should == 'PASSWORD'
    end
  end

  describe Elk::Number do
    it 'allocates a number' do
      stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers").
        with(:body => "sms_url=http%3A%2F%2Flocalhost%2Freceive&country=se",
             :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(fixture('allocates_a_number.txt'))


      elk = Elk::Account.new(:username => 'USERNAME', :password => 'PASSWORD')
      number = Elk::Number.allocate(:account => elk, :sms_url => 'http://localhost/receive', :country => 'se')
      number.status.should == :active
      number.sms_url.should == 'http://localhost/receive'
      number.country.should == 'se'
      number.number.should == '+46766861012'
    end

    it 'gets allocated numbers' do
      stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers").
        with(:headers => {'Accept'=>'application/json'}).
        to_return(fixture('gets_allocated_numbers.txt'))

      elk = Elk::Account.new(:username => 'USERNAME', :password => 'PASSWORD')
      numbers = Elk::Number.numbers(:account => elk)
      numbers.size.should == 2
      numbers[0].number_id.should == 'nea19c8e291676fb7003fa1d63bba7899'
      numbers[0].number.should == '+46704508449'
      numbers[0].sms_url == 'http://localhost/receive1'

      numbers[1].number_id.should == 'nea19c8e291676fb7003fa1d63bba789A'
      numbers[1].number.should == '+46761042247'
      numbers[0].sms_url == 'http://localhost/receive2'
    end
  end

  describe Elk::SMS do
    it 'sends a SMS' do
      stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS").
        with(:body => "from=%2B46761042247&to=%2B46704508449&message=Your%20order%20%23171%20has%20now%20been%20sent!",
             :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(fixture('sends_a_sms.txt'))

      elk = Elk::Account.new(:username => 'USERNAME', :password => 'PASSWORD')
      sms = Elk::SMS.send(:account => elk, :from => '+46761042247',
        :to => '+46704508449',
        :message => 'Your order #171 has now been sent!')
      #sms.status.should == Elk::SMS::Sent
    end
  end
end