# frozen_string_literal: true

require "spec_helper"
require "elk"

describe Elk::Client do
  it { is_expected.to respond_to(:configure) }
  it { is_expected.to respond_to(:base_url) }
  it { is_expected.to respond_to(:base_domain) }
  it { is_expected.to respond_to(:username) }
  it { is_expected.to respond_to(:username=) }
  it { is_expected.to respond_to(:password) }
  it { is_expected.to respond_to(:password=) }

  let(:username) { "username" }
  let(:password) { "password" }

  it "should accept username and password" do
    client = Elk::Client.new(username: username, password: password)
    expect(client.username).to eq(username)
    expect(client.password).to eq(password)
  end

  describe ".base_url" do
    context "detect missing username and/or password" do
      context "when nothing is configured" do
        specify do
          subject.configure do |config|
            config.username = nil
            config.password = nil
          end

          expect { subject.base_url }.to raise_error(Elk::AuthError)
        end
      end

      context "when username is missing" do
        specify do
          subject.configure do |config|
            config.username = nil
            config.password = "PASSWORD"
          end

          expect { subject.base_url }.to raise_error(Elk::AuthError)
        end
      end

      context "when password is missing" do
        specify do
          subject.configure do |config|
            config.username = "USERNAME"
            config.password = nil
          end

          expect { subject.base_url }.to raise_error(Elk::AuthError)
        end
      end

      context "when all is configured" do
        specify do
          subject.configure do |config|
            config.username = "USERNAME"
            config.password = "PASSWORD"
          end

          expect { subject.base_url }.not_to raise_error
        end
      end
    end
  end
end
