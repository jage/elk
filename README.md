Elk
===

Ruby client for 46elks "Voice, SMS & MMS" service. http://46elks.com/
At the moment the API only supports sending SMS messages.

## Requirements

* API account at 46elks.com

## Install

Install via RubyGems

    gem install elk

## Source and development

The source for Elk is available on Github:

    https://github.com/jage/elk

elk uses rspec and webmock for testing, do a `bundle install` for all the development requirements.

## Usage

elk can be used to allocate a phone numbers, manage the numbers and send/recieve messages through these numbers.

### Authentication and configuration

First thing when using elk is to set the authentication parameters

    require 'elk'

    Elk.configure do |config|
      config.username = 'USERNAME'
      config.password = 'PASSWORD'
    end

### Numbers

To be able to send and recieve messages, a number is needed. Several numbers can be allocated.

    number = Elk::Number.allocate(:sms_url => 'http://myservice.se/callback/newsms.php', :country => 'se')
    # => #<Elk::Number:0x0000010282aa70 @country="se", @sms_url="http://myservice.se/callback/newsms.php", @status="yes", @number_id="n03e7db70cc06c1ff85e09a2b3f86dd62", @number="+46766861034", @capabilities=[:sms], @loaded_at=2011-07-17 15:23:55 +0200>

Get all numbers

    numbers = Elk::Number.all
    # => [#<Elk::Number ...>, #<Elk::Number ...>]

Change number settings

    number.sms_url = 'http://myservice.se/callback/newsms.php'
    number.country = 'no'
    number.save
    # => true

Deallocate a number.
Beware that there is no way to get your number back once it has been deallocated!

    number.deallocate!
    # => true
    number.status
    # => :deallocated

### SMS

Send SMS. Messages can be sent from one of the allocated numbers or an arbitrary alphanumeric string of at most 11 characters.

    Elk::SMS.send(:from => 'MyService', :to => '+46704508449', :message => 'Your order #171 has now been sent!')
    # => #<Elk::SMS:0x0000010179d7e8 @from="MyService", @to="+46704508449", @message="Your order #171 has now been sent!", @message_id="sdc39a7926d37159b6985283e32f43251", @created_at=2011-07-17 16:21:13 +0200, @loaded_at=2011-07-17 16:21:13 +0200>

Receiving SMS does not require Elk, but should be of interest anyway.
Example with Sinatra:

    post '/receive' do
      if request.params['message'] == 'Hello'
        # Sends a return SMS with message "world!"
        "world!"
      end
    end

SMS history

    Elk::SMS.all
    # => [#<Elk::SMS ...>, #<Elk::SMS ...>, <Elk::SMS ...>]

## Copyright

Copyright (c) 2011 Johan Eckerström. See LICENSE for details.