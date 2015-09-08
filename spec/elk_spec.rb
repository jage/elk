require "spec_helper"
require "elk"

describe Elk do

  subject { Elk }

  it { is_expected.to respond_to(:client) }
  it { is_expected.to respond_to(:username) }
  it { is_expected.to respond_to(:username=) }
  it { is_expected.to respond_to(:password) }
  it { is_expected.to respond_to(:password=) }

  describe ".client" do
    it "should reuse the same client object" do
      expect(Elk.client.object_id).to eq(Elk.client.object_id)
    end
  end

  describe ".base_url" do
    context "detect missing username and/or password" do
      context "when nothing is configured" do
        specify do
          Elk.configure do |config|
            config.username = nil
            config.password = nil
          end

          expect { Elk.base_url }.to raise_error(Elk::AuthError)
        end
      end

      context "when username is missing" do
        specify do
          Elk.configure do |config|
            config.username = nil
            config.password = "PASSWORD"
          end

          expect { Elk.base_url }.to raise_error(Elk::AuthError)
        end
      end

      context "when password is missing" do
        specify do
          Elk.configure do |config|
            config.username = "USERNAME"
            config.password = nil
          end

          expect { Elk.base_url }.to raise_error(Elk::AuthError)
        end
      end

      context "when all is configured" do
        specify do
          Elk.configure do |config|
            config.username = "USERNAME"
            config.password = "PASSWORD"
          end

          expect { Elk.base_url }.not_to raise_error
        end
      end
    end
  end

  describe ".parse_json" do
    context "with empty object body" do
      let(:body) { "{}" }

      it "should return empty hash" do
        expect(Elk.parse_json(body)).to eq({})
      end
    end

    context "with garbage json" do
      let(:body) { fixture("bad_response_body.txt").read }

      it "should raise bad response exception" do
        expect { Elk.parse_json(body) }.to raise_error(Elk::BadResponse)
      end
    end
  end
end
