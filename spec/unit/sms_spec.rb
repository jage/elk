# frozen_string_literal: true

require "spec_helper"
require "elk"
require "json"

describe Elk::SMS do
  subject(:sms) { described_class.new({}) }

  let(:client) { instance_double(Elk::Client) }

  describe "#new" do
    context "when passing a client" do
      subject(:sms) { described_class.new(client: client) }

      it "should use the passed in client" do
        expect(sms.client).to eq(client)
      end
    end

    context "without passing a client" do
      it "should instantiate a client" do
        expect(sms.client).to be_an(Elk::Client)
      end
    end
  end

  describe ".send" do
    let(:sms_response) { double("Response", body: JSON.dump({}) ) }

    context "when passing a client" do
      it "should use the passed in client" do
        expect(client).to receive(:post)
          .with("/SMS", from: "", to: "", message: "") { sms_response }
        described_class.send(client: client, from: "", to: "", message: "")
      end
    end

    context "without passing a client" do
      it "should instantiate a client" do
        expect_any_instance_of(Elk::Client).to receive(:post)
          .with("/SMS", from: "", to: "", message: "") { sms_response }
        described_class.send(from: "", to: "", message: "")
      end
    end

  end

  describe ".all" do
    let(:all_response) { double("Response", body: JSON.dump(data: []) ) }

    context "when passing a client" do
      it "should use the passed in client" do
        expect(client).to receive(:get)
          .with("/SMS") { all_response }
        described_class.all(client: client)
      end
    end

    context "without passing a client" do
      it "should instantiate a client" do
        expect_any_instance_of(Elk::Client).to receive(:get)
          .with("/SMS") { all_response }
        described_class.all
      end
    end
  end
end
