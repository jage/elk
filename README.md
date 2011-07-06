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
    Elk::Account

### Authentication

    require 'elk'
    elk = Elk::Account.new(:username => 'USERNAME', :password => 'PASSWORD', :base_url => 'https://api.46elks.com/a1/')

### Number allocation

    elk.allocate_number(:sms_url => 'http://myservice.se/callback/newsms.php', :country => 'se')
     # => Elk::Number

    elk.numbers.allocate(:sms_url => 'http://myservice.se/callback/newsms.php', :country => 'se')
     # => Elk::Number

    elk.numbers
     # => [Elk::Number, Elk::Number]

    Elk::Number.allocate(:sms_url => 'http://myservice.se/callback/newsms.php', :account => elk, :country => 'se')
     # => [Elk::Number]

### Number deallocation

Deallocates the number. Beware that there is no way to get your number back once it has been deallocated!

    number.deallocate!

### Change receive URL

    number.change(:sms_url => 'http://myservice.se/callback/newsms.php')

### Send SMS

    Elk::SMS.send(elk, :from => '+46761042247 or “MyService”', :to => '+46704508449', :message => 'Your order #171 has now been sent!')
    elk.send_sms(:from => '+46761042247 or “MyService”', :to => '+46704508449', :message => 'Your order #171 has now been sent!')
    # Defaults to the accounts first number
    elk.send_sms(:to => '+46704508449', :message => 'Your order #171 has now been sent!')

### Receive SMS

    receive(parameters)

Example with Sinatra:

    post '/receive' do
      sms = Elk::SMS.receive(request)

      if sms[:message] == 'Hello'
        "world!"
      end
    end

### SMS History

    elk.sms_history
     # => [Elk::SMS, Elk::SMS, Elk::SMS]
     # => [{:to => "+9999999999", :message => "hello", :from => "+9999999999", :id => "aoe8uaoe98uaoe", :created => "2011-07-04T17:44:51.508000"}, {:to => "+9999999999", :message => "world!", :from => "+9999999999", :id => "baoaoe8uao9eu", :created => "2011-07-04T17:44:48.048000"}]

## Copyright

Copyright (c) 2011 Johan Eckerström. See LICENSE for details.