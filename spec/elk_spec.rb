require 'spec_helper'
require 'elk'

describe Elk do
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
          config.password = 'PASSWORD'
        end

        expect { Elk.base_url }.to raise_error(Elk::AuthError)
      end
    end

    context "when password is missing" do
      specify do
        Elk.configure do |config|
          config.username = 'USERNAME'
          config.password = nil
        end

        expect { Elk.base_url }.to raise_error(Elk::AuthError)
      end
    end

    context "when all is configured" do
      specify do
        Elk.configure do |config|
          config.username = 'USERNAME'
          config.password = 'PASSWORD'
        end

        expect { Elk.base_url }.not_to raise_error
      end
    end
  end

  it 'should handle garbage json' do
    bad_response_body = fixture('bad_response_body.txt').read

    expect {
      Elk.parse_json(bad_response_body)
    }.to raise_error(Elk::BadResponse)
  end
end
