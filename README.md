# Reverb::Api

An ruby gem to interact with the Reverb api.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'reverb-api'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install reverb-api

## Usage

The main object you will use is `Reverb::Api::Client`.

Right now this only implements `#authenticate`, `#create_listing`, and `#find_listing_by_sku` 
methods along with general`#get`, `#post`, `#put`, and `#delete` methods where you specify 
the path manually.

Examples:

    client = Reverb::Api::Client.new(reverb_token: 'MY_TOKEN')

    client.create_listing make: "Fender", model: "Precision Bass", sku: "THE_SKU"
    client.find_listing_by_sku "THE_SKU"

## Testing

The specs make real requests against Reverb's sandbox server which requires secret
usernames and passwords. As a result, you will likely not be able to run them locally.
Sorry.
