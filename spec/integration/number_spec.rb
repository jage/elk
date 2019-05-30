# frozen_string_literal: true

require "spec_helper"
require "elk"

describe Elk::Number do
  before { configure_elk }
  let(:username) { "USERNAME" }
  let(:password) { "PASSWORD" }
  let(:basic_auth) { [username, password] }
  let(:url) { "https://api.46elks.com/a1/Numbers" }

  describe ".allocate" do
    context "swedish sms number" do
      let(:sms_url)   { 'http://localhost/receive' }
      let(:country)   { 'se' }
      let(:arguments) { { sms_url: sms_url, country: country } }

      subject(:number) { described_class.allocate(arguments) }

      before(:each) do
        stub_request(:post, url).
          with(body: arguments,
               headers: post_headers).
          to_return(fixture('allocates_a_number.txt'))
      end

      it { is_expected.to have_attributes(arguments) }

      it "should be active" do
        expect(number.status).to eq(:active)
      end

      it "should have a new swedish number" do
        expect(number.number).to match(/\+46\d+/)
      end

      it "should have sms capabilities" do
        expect(number.capabilities).to include(:sms)
      end
    end

    context "without arguments" do
      it 'should raise exception' do
        expect {
          described_class.allocate({})
        }.to raise_error(Elk::MissingParameter)
      end
    end
  end

  describe ".all" do
    context "with two allocated numbers" do
      before(:each) do
        stub_request(:get, url).
          with(headers: get_headers).
          to_return(fixture('gets_allocated_numbers.txt'))
      end

      subject(:numbers) { described_class.all }

      it "should return two numbers" do
        expect(numbers.size).to eq(2)
      end

      it "should have different number id:s" do
        expect(numbers.first.number_id).to_not be eq(numbers.last.number_id)
      end

      it "should have different phone numbers" do
        expect(numbers.first.number).to_not be eq(numbers.last.number)
      end

      context "first numbers sms_url" do
        subject(:number) { numbers[0].sms_url }
        it { is_expected.to eq('http://localhost/receive1') }
      end

      context "second numbers sms_url" do
        subject(:number) { numbers[1].sms_url }
        it { is_expected.to eq('http://localhost/receive2') }
      end
    end

    context "with wrong password" do
      let(:url) { "https://api.46elks.com/a1/Numbers" }
      let(:password) { "WRONG" }

      before(:each) do
        stub_request(:get, url).
          with(headers: get_headers, basic_auth: basic_auth).
          to_return(fixture('auth_error.txt'))

        Elk.configure do |config|
          config.username = username
          config.password = password
        end
      end

      it 'should raise authentication error' do
        expect {
          described_class.all
        }.to raise_error(Elk::AuthError)
      end
    end

    context "when server is broken" do
      before(:each) do
        stub_request(:get, url).
          with(headers: get_headers).
          to_return(fixture('server_error.txt'))
      end

      it 'should raise server error' do
        expect {
          described_class.all
        }.to raise_error(Elk::ServerError)
      end
    end
  end

  describe "#save" do
    before(:each) do
      stub_request(:get, url).
        with(headers: get_headers, basic_auth: basic_auth).
        to_return(fixture('gets_allocated_numbers.txt'))

      stub_request(:post, "#{url}/nea19c8e291676fb7003fa1d63bba7899").
        with(body: {"sms_url" => "http://otherhost/receive", "voice_start" => nil},
        headers: post_headers, basic_auth: basic_auth).
        to_return(fixture('updates_a_number.txt'))
    end

    subject(:number) { described_class.all.first }

    it 'should update a number' do
      number.country = 'no'
      number.sms_url = 'http://otherhost/receive'

      expect(number.save).to be(true)
    end
  end

  describe "#deallocate!" do
    before(:each) do
      stub_request(:get, url).
        with(headers: get_headers).
        to_return(fixture('gets_allocated_numbers.txt'))

      stub_request(:post, "#{url}/nea19c8e291676fb7003fa1d63bba7899").
        with(body: {"active" => "no"},
        headers: post_headers).
        to_return(fixture('deallocates_a_number.txt'))
    end

    subject(:number) { described_class.all.first }

    it "should return true" do
      expect(number.deallocate!).to be(true)
    end

    it "should update loaded_at" do
      expect { number.deallocate! }.to change { number.status }.to(:deallocated)
    end
  end

  describe "#reload" do
    before(:each) do
      stub_request(:get, url).
        with(headers: get_headers).
        to_return(fixture('gets_allocated_numbers.txt'))

      stub_request(:get, "#{url}/nea19c8e291676fb7003fa1d63bba7899").
        with(headers: get_headers).
        to_return(fixture('reloads_a_number.txt'))
    end

    subject(:number) { described_class.all.first }

    it "should return true" do
      expect(number.reload).to be(true)
    end

    it "should not change object_id" do
      expect { number.reload }.to_not change { number.object_id }
    end

    it "should update loaded_at" do
      expect { number.reload }.to change { number.loaded_at }
    end

    it "should reset mutations" do
      number.country = "blah"
      expect { number.reload }.to change { number.country }.to("se")
    end
  end
end
