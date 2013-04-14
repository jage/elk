require 'spec_helper'
require 'elk'

describe Elk::SMS do
  before { configure_elk }

  it 'sends a SMS' do
    stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS").
      with(:body => {:from => "+46761042247", :message => "Your order #171 has now been sent!", :to => "+46704508449"},
           :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
      to_return(fixture('sends_a_sms.txt'))

    # Fake $stderr to check warnings
    begin
      old_stderr, $stderr = $stderr, StringIO.new

      sms = described_class.send(:from => '+46761042247',
        :to => '+46704508449',
        :message => 'Your order #171 has now been sent!')

      $stderr.string.should == ""
    ensure
      $stderr = old_stderr
    end

    sms.class.should == described_class
    sms.from.should == '+46761042247'
    sms.to.should == '+46704508449'
    sms.message.should == 'Your order #171 has now been sent!'
    sms.direction.should == 'outgoing'
    sms.status.should == 'delivered'
  end

  context 'when sending a SMS to multiple recipients' do
    before do
      stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS").
        with(:body => {:from => "+46761042247", :message => "Your order #171 has now been sent!", :to => "+46704508449,+46704508449"},
             :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
        to_return(fixture('sends_a_sms_to_multiple_recipients.txt'))
    end        

    it "sends the SMS when passing `to` as comma separated string" do
      smses = described_class.send(:from => '+46761042247',
        :to => '+46704508449,+46704508449',
        :message => 'Your order #171 has now been sent!')

      smses.size.should == 2
      smses[0].class.should == described_class
      smses[0].to.should == "+46704508449"

      smses[0].message_id.should == "sb326c7a214f9f4abc90a11bd36d6abc3"
      smses[1].message_id.should == "s47a89d6cc51d8db395d45ae7e16e86b7"
    end

    it "sends the SMS when passing `to` as array" do
      smses = described_class.send(:from => '+46761042247',
        :to => ['+46704508449', '+46704508449'],
        :message => 'Your order #171 has now been sent!')

      smses.size.should == 2
      smses[0].class.should == described_class
      smses[0].to.should == "+46704508449"

      smses[0].message_id.should == "sb326c7a214f9f4abc90a11bd36d6abc3"
      smses[1].message_id.should == "s47a89d6cc51d8db395d45ae7e16e86b7"
    end
  end

  it 'gets SMS-history' do
    stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS").
      with(:headers => {'Accept'=>'application/json'}).
      to_return(fixture('sms_history.txt'))

    sms_history = described_class.all

    sms_history.size.should == 3
    sms_history[0].class.should == described_class
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

    sms_history = described_class.all
    sms = sms_history[0]
    loaded_at = sms.loaded_at
    object_id = sms.object_id
    sms.reload.should == true
    sms.object_id.should == object_id
    sms.loaded_at.should_not == loaded_at
  end

  it 'should warn about capped sms sender' do
    stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS").
      with(:body => {:from => "VeryVeryVeryVeryLongSenderName", :message => "Your order #171 has now been sent!", :to => "+46704508449"},
           :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
      to_return(fixture('sends_a_sms_with_long_sender.txt'))

    # Fake $stderr to check warnings
    begin
      old_stderr, $stderr = $stderr, StringIO.new

      sms = described_class.send(:from => 'VeryVeryVeryVeryLongSenderName',
        :to => '+46704508449',
        :message => 'Your order #171 has now been sent!')

      $stderr.string.should == "SMS 'from' value VeryVeryVeryVeryLongSenderName will be capped at 11 chars\n"
    ensure
      $stderr = old_stderr
    end

    sms.class.should == described_class
    sms.from.should == 'VeryVeryVeryVeryLongSenderName'
    sms.to.should == '+46704508449'
    sms.message.should == 'Your order #171 has now been sent!'
  end

  it 'should handle invalid to number' do
    stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/SMS").
      with(:body => {:from => "+46761042247", :message => "Your order #171 has now been sent!", :to => "monkey"},
           :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
      to_return(fixture('invalid_to_number.txt'))

    expect {
      sms = described_class.send(:from => '+46761042247',
        :to => 'monkey',
        :message => 'Your order #171 has now been sent!')
    }.to raise_error(Elk::BadRequest, 'Invalid to number')
  end

  it 'should handle no parameters' do
    expect {
      sms = described_class.send({})
    }.to raise_error(Elk::MissingParameter)
  end
end