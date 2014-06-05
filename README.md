# AdLeads
Wrapper for the Adleads JSON api.

## Installation

Add this line to your application's Gemfile:

    gem 'ad_leads'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ad_leads

## Usage
Steps are outline by request here - https://api.adleads.com/doc/index.html#tutorial

    AdLeads.configure do |config|
      config.client_id = ENV['AD_LEADS_CLIENT_ID'],
      config.principle = ENV['AD_LEADS_PRINCIPLE'],
      config.private_key = ENV['AD_LEADS_PRIVATE_KEY']
    end

    client = AdLeads::Client.new

## Contributing

1. Fork it ( http://github.com/<my-github-username>/ad_leads/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
