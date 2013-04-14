require 'spec_helper'
require 'elk'

describe Elk do
  it 'should detect missing username and/or password' do
    expect { described_class.base_url }.to raise_error(described_class::AuthError)

    described_class.configure do |config|
      config.username = nil
      config.password = 'PASSWORD'
    end

    expect { described_class.base_url }.to raise_error(described_class::AuthError)

    described_class.configure do |config|
      config.username = 'USERNAME'
      config.password = nil
    end

    expect { described_class.base_url }.to raise_error(described_class::AuthError)

    described_class.configure do |config|
      config.username = 'USERNAME'
      config.password = 'PASSWORD'
    end

    expect { described_class.base_url }.to_not raise_error(described_class::AuthError)
  end

  it 'should handle garbage json' do
    bad_response_body = fixture('bad_response_body.txt').read

    expect {
      described_class.parse_json(bad_response_body)
    }.to raise_error(described_class::BadResponse)
  end
end