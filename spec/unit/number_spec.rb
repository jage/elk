require "spec_helper"
require "elk"
require "json"

describe Elk::Number do
  subject(:number) { described_class.new({}) }

  let(:client) { instance_double(Elk::Client) }

  describe "#new" do
    context "when passing a client" do
      subject(:number) { described_class.new(client: client) }

      it "should use the passed in client" do
        expect(number.client).to eq(client)
      end
    end

    context "without passing a client" do
      it "should instantiate a client" do
        expect(number.client).to be_an(Elk::Client)
      end
    end
  end

  describe ".allocate" do
    let(:allocate_response) { double("Response", body: JSON.dump({}) ) }

    context "when passing a client" do
      it "should use the passed in client" do
        expect(client).to receive(:post) { allocate_response }
        described_class.allocate(client: client, country: "no")
      end
    end

    context "without passing a client" do
      it "should instantiate a client" do
        expect_any_instance_of(Elk::Client).to receive(:post) { allocate_response }
        described_class.allocate(country: "no")
      end
    end
  end

  describe ".all" do
    let(:all_response) { double("Response", body: JSON.dump(data: []) ) }

    context "when passing a client" do
      it "should use the passed in client" do
        expect(client).to receive(:get) { all_response }
        described_class.all(client: client)
      end
    end

    context "without passing a client" do
      it "should instantiate a client" do
        expect_any_instance_of(Elk::Client).to receive(:get) { all_response }
        described_class.all
      end
    end
  end
end
