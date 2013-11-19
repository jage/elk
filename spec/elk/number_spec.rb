require 'spec_helper'
require 'elk'

describe Elk::Number do
  before { configure_elk }

  it 'allocates a number' do
    stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers").
      with(:body => {"country" => "se", "sms_url" => "http://localhost/receive"},
           :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
      to_return(fixture('allocates_a_number.txt'))

    number = described_class.allocate(:sms_url => 'http://localhost/receive', :country => 'se')

    number.status.should       == :active
    number.sms_url.should      == 'http://localhost/receive'
    number.country.should      == 'se'
    number.number.should       == '+46766861012'
    number.capabilities.should == [:sms]
  end

  it 'gets allocated numbers' do
    stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers").
      with(:headers => {'Accept'=>'application/json'}).
      to_return(fixture('gets_allocated_numbers.txt'))

    numbers = described_class.all

    numbers.size.should         == 2
    numbers[0].number_id.should == 'nea19c8e291676fb7003fa1d63bba7899'
    numbers[0].number.should    == '+46704508449'
    numbers[0].sms_url          == 'http://localhost/receive1'

    numbers[1].number_id.should == 'nea19c8e291676fb7003fa1d63bba789A'
    numbers[1].number.should    == '+46761042247'
    numbers[0].sms_url          == 'http://localhost/receive2'
  end

  it 'updates a number' do
    stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers").
      with(:headers => {'Accept'=>'application/json'}).
      to_return(fixture('gets_allocated_numbers.txt'))
    stub_request(:post, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers/nea19c8e291676fb7003fa1d63bba7899").
      with(:body => {"sms_url" => "http://otherhost/receive", "voice_start" => ""},
      :headers => {'Accept'=>'application/json', 'Content-Type'=>'application/x-www-form-urlencoded'}).
      to_return(fixture('updates_a_number.txt'))

    number = described_class.all[0]
    number.country = 'no'
    number.sms_url = 'http://otherhost/receive'

    number.save.should    == true
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

    number = described_class.all[0]

    number.status.should      == :active
    number.deallocate!.should == true
    number.status.should      == :deallocated
  end

  it 'reloads a number' do
    stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers").
      with(:headers => {'Accept'=>'application/json'}).
      to_return(fixture('gets_allocated_numbers.txt'))
    stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers/nea19c8e291676fb7003fa1d63bba7899").
      with(:headers => {'Accept'=>'application/json'}).
      to_return(fixture('reloads_a_number.txt'))

    number = described_class.all[0]
    object_id = number.object_id
    loaded_at = number.loaded_at
    number.country = 'blah'

    number.reload.should        == true
    number.country.should       == 'se'
    number.object_id.should     == object_id
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
      described_class.all
    }.to raise_error(Elk::AuthError)
  end

  it 'gets server error when looking for all numbers' do
    stub_request(:get, "https://USERNAME:PASSWORD@api.46elks.com/a1/Numbers").
      with(:headers => {'Accept'=>'application/json'}).
      to_return(fixture('server_error.txt'))

    expect {
      described_class.all
    }.to raise_error(Elk::ServerError)
  end

  it 'should handle no parameters' do
    expect {
      sms = described_class.allocate({})
    }.to raise_error(Elk::MissingParameter)
  end
end
