Elk
===

Ruby client for 46elks "Voice, SMS & MMS" service.

## Requirements

* Ruby 1.9.2
* API account at 46elks.com

## Install

Install via RubyGems

    gem install elk

## Source

The source for elk is available on Github:

    https://github.com/jage/elk

### Development

elk uses rspec and webmock for testing, do a `bundle install` for all the development requirements.

## Usage

elk is a client to allocate a SMS number, send and receive SMS (receiving SMS requires you to run a HTTP server).

### Classs

    Elk::SMS
    Elk::Number

### Authentication and configuration

    require 'elk'

    Elk.configure do |config|
      config.username = 'USERNAME'
      config.password = 'PASSWORD'
    end

### Number allocation

    number = Elk::Number.allocate(:sms_url => 'http://myservice.se/callback/newsms.php', :country => 'se')
     # => Elk::Number
    number.number
     # => '+46704508449'
    number.status
     # => :active
    number.capabilities
     # => [:sms]

    Elk::Number.all
     # => [Elk::Number]

### Number deallocation

Deallocates the number. Beware that there is no way to get your number back once it has been deallocated!

    number.deallocate!
     # => true
    number.status
     # => :deallocated

### Change number settings

    number.sms_url = 'http://myservice.se/callback/newsms.php'
    number.country = 'no'
    number.save
     # => true

### Send SMS

    Elk::SMS.send(:from => '+46761042247 or “MyService”', :to => '+46704508449', :message => 'Your order #171 has now been sent!')
     # => Elk::SMS
    # Defaults to the accounts first number
    Elk::SMS.send(:to => '+46704508449', :message => 'Your order #171 has now been sent!')
     # => Elk::SMS

### Receive SMS

Receiving SMS does not require Elk, but should be of interest anyway.
Example with Sinatra:

    post '/receive' do
      if request.params['message'] == 'Hello'
        # Sends a return SMS with message "world!"
        "world!"
      end
    end

### SMS History

    Elk::SMS.all
     # => [Elk::SMS, Elk::SMS, Elk::SMS]

## Copyright

Copyright (c) 2011 Johan Eckerström. See LICENSE for details.