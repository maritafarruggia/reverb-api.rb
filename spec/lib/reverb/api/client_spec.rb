require 'spec_helper'

describe Reverb::Api::Client, vcr: true do
  let(:client) do
    described_class.new(
      basic_auth: basic_auth,
      reverb_token: reverb_token,
      url: url
    )
  end

  let(:basic_auth) do
    {
      username: ENV["REVERB_SANDBOX_USERNAME"],
      password: ENV["REVERB_SANDBOX_PASSWORD"]
    }
  end

  let(:email) { "exampleuser@gmail.com" }
  let(:password) { "password" }
  let(:reverb_token) { ENV["REVERB_TEST_API_TOKEN"] }
  let(:url) { "https://sandbox.reverb.com" }

  describe "#authenticate", vcr: { cassette_name: "authenticate" } do
    specify do
      client.authenticate(email, password).code.should == 201
    end
  end

  describe "#create_listing", vcr: { cassette_name: "create_listing" } do
    specify do
      client.create_listing({
        make: "Fender",
        model: "Stratocaster",
        sku: "ASKU"
      }).code.should == 201
    end
  end

  describe "#find_listing_by_sku", vcr: { cassette_name: "find_listing_by_sku" } do

    context "the sku is found on reverb" do
      let(:listing) { client.find_listing_by_sku("ASKU") }

      it "finds the correct item" do
        listing.make.should == "Fender"
        listing.model.should == "Stratocaster"
      end
    end

    context "the sku is not found on reverb" do
      let(:listing) { client.find_listing_by_sku("NOSKU") }

      it "is nil" do
        listing.should === nil
      end
    end
  end

  describe "updating listing", vcr: { cassette_name: "update_listing" } do
    let(:listing) { client.find_listing_by_sku("ASKU") }

    it "updates" do
      listing.update(title: "new title")

      # This test can fail because there is an undefined amount of time before
      # the update above is represented in the search below (due to ElasticSearch)
      client.find_listing_by_sku("ASKU").title.should == "new title"
    end
  end
end

