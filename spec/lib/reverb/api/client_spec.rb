require 'spec_helper'

describe Reverb::Api::Client, vcr: true do
  let(:client) do
    described_class.new(
      reverb_token: reverb_token,
      url: url
    )
  end

  let(:email) { "foobar@foobar.com" }
  let(:password) { "foobar123" }
  let(:reverb_token) { "mangled_token" }
  let(:url) { "https://sandbox.reverb.com" }

  context "service is down", vcr: { cassette_name: "service_down" } do
    let(:url) { "https://reverb.com" }
    it "raises a NotAuthorizedError" do
      expect { client.find_listing_by_sku("THETESTSKU") }
        .to raise_error Reverb::Api::ServiceDown
    end
  end

  context "with invalid authentication", vcr: { cassette_name: "wrong_auth" } do

    context "bad api token" do
      let(:reverb_token) { "bad_token" }

      it "raises a NotAuthorizedError" do
        expect { client.find_listing_by_sku("THETESTSKU") }
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

    describe "#create_listing", vcr: { cassette_name: "create_listing", record: :none} do
      specify do
        client.create_listing({
          make: "Fender",
          model: "Stratocaster",
          sku: "TESTSKU1234"
        }).code.should == 201
      end
    end

    describe "#find_listing_by_sku", vcr: { cassette_name: "find_listing_by_sku", record: :new_episodes } do

      context "the sku is found on reverb" do
        let(:listing) { client.find_listing_by_sku("THETESTSKU") }

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

      context "the sku contains a plus" do
        before do
          client.create_listing({
            make: "Fender",
            model: "Stratocaster",
            sku: "THE+SKU"
          })
        end

        let(:listing) { client.find_listing_by_sku("THE+SKU") }

        it "still finds listing" do
          listing.should be_truthy
        end
      end
    end

    describe "#find_draft", vcr: { cassette_name: "find_draft" } do

      context "the sku is found on reverb" do
        let(:listing) { client.find_draft("THETESTSKU") }

        it "finds the correct item" do
          listing.make.should == "Fender"
          listing.model.should == "Stratocaster"
        end
      end

      context "the sku is not found on reverb", vcr: { record: :none} do
        let(:listing) { client.find_draft("NOSKU") }

        it "is nil" do
          listing.should === nil
        end
      end
    end

    describe "updating listing", vcr: { cassette_name: "update_listing" } do
      let(:listing) { client.find_listing_by_sku("THETESTSKU") }

      it "updates" do
        listing.update(title: "new title")

        # This test can fail because there is an undefined amount of time before
        # the update above is represented in the search below (due to ElasticSearch)
        client.find_listing_by_sku("THETESTSKU").title.should == "new title"
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

    describe "adding headers" do
      before do
        stub_request(:get, "https://sandbox.reverb.com/api/webhooks/registrations")
        client.add_default_header({"User-Agent" => "An-Agent" })
        client.webhooks
      end

      it "adds headers to requests" do
        WebMock.should have_requested(:get, "https://sandbox.reverb.com/api/webhooks/registrations").
          with(headers: { "User-Agent" => "An-Agent" })
      end
    end

    describe 'specifying oauth_token' do
      let(:oauth_token) { 'oauth_token' }

      let(:client) do
        described_class.new(
          oauth_token: oauth_token,
          url: url
        )
      end

      before do
        stub_request(:get, "https://sandbox.reverb.com/api/webhooks/registrations")
        client.webhooks
      end

      it "adds the Bearer token to the request" do
        WebMock.should have_requested(:get, "https://sandbox.reverb.com/api/webhooks/registrations").
          with(headers: { "Authorization" => "Bearer #{oauth_token}" })
      end

    end

    describe 'specifying api version' do
      let(:api_version) { '3.0' }
      let(:client) do
        described_class.new(
          url: url,
          api_version: api_version
        )
      end

      before do
        stub_request(:get, "https://sandbox.reverb.com/api/webhooks/registrations")
        client.webhooks
      end

      it "puts the Accept-Version in the header" do
        WebMock.should have_requested(:get, "https://sandbox.reverb.com/api/webhooks/registrations").
          with(headers: { "Accept-Version" => api_version })
      end
    end

    context 'with full urls' do
      let(:full_url) { "https://api.reverb.com/api/resource" }

      before do
        stub_request(:get, full_url)
        client.get(full_url)
      end

      it 'does not try to append the url' do
        WebMock.should have_requested(:get, full_url)
      end
    end

    context 'with relative urls' do
      let(:relative_url) { "/api/resource" }
      let(:full_url) { "https://sandbox.reverb.com#{relative_url}" }

      before do
        stub_request(:get, full_url)
        client.get(relative_url)
      end

      it 'does not try to append the url' do
        WebMock.should have_requested(:get, full_url)
      end

    end
  end
end
