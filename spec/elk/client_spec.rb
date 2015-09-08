require "spec_helper"
require "elk"

describe Elk::Client do
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
end
