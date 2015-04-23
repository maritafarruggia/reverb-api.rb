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

  context "with invalid authentication", vcr: { cassette_name: "wrong_auth" } do

    context "bad basic auth" do
      let(:basic_auth) { { username: "WRONG", password: "WRONG" } }

      it "raises a NotAuthorizedError" do
        expect { client.find_listing_by_sku("THESKU") }
          .to raise_error Reverb::Api::NotAuthorizedError, "Reverb authorization failed. Please check your X-Auth-Token header."
      end
    end

    context "bad api token" do
      let(:reverb_token) { "bad_token" }

      it "raises a NotAuthorizedError" do
        expect { client.find_listing_by_sku("THESKU") }
          .to raise_error Reverb::Api::NotAuthorizedError, "Please log in to view your listings."
      end

    end
  end

  context "with valid authentication" do

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
          sku: "THESKU"
        }).code.should == 201
      end
    end

    describe "#find_listing_by_sku", vcr: { cassette_name: "find_listing_by_sku" } do

      context "the sku is found on reverb" do
        let(:listing) { client.find_listing_by_sku("THESKU") }

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

    describe "#find_draft", vcr: { cassette_name: "find_draft" } do

      context "the sku is found on reverb" do
        let(:listing) { client.find_draft("THESKU") }

        it "finds the correct item" do
          listing.make.should == "Fender"
          listing.model.should == "Stratocaster"
        end
      end

      context "the sku is not found on reverb" do
        let(:listing) { client.find_draft("NOSKU") }

        it "is nil" do
          listing.should === nil
        end
      end
    end

    describe "updating listing", vcr: { cassette_name: "update_listing" } do
      let(:listing) { client.find_listing_by_sku("THESKU") }

      it "updates" do
        listing.update(title: "new title")

        # This test can fail because there is an undefined amount of time before
        # the update above is represented in the search below (due to ElasticSearch)
        client.find_listing_by_sku("THESKU").title.should == "new title"
      end
    end

    describe "#create_webhook", vcr: { cassette_name: "create_webhook" } do
      before do
        hook = client.webhooks["registrations"].find { |hook| hook["url"] == "http://requestb.in/1etnuhm1" }
        if hook
          client.delete(hook["_links"]["self"]["href"], {})
        end
      end

      specify do
        client.create_webhook(url: "http://requestb.in/1etnuhm1", topic: "listings/update")
          .code.should == 201
      end
    end

    describe "#webhooks", vcr: { cassette_name: "get_webhooks" } do
      subject(:registered_webhook) { client.webhooks["registrations"].find { |hook| hook["url"] == "http://requestb.in/1etnuhm1" } }

      it "gets registered webhooks" do
        subject["url"].should == "http://requestb.in/1etnuhm1"
        subject["topic"].should == "listings/update"
      end
    end
  end
end
