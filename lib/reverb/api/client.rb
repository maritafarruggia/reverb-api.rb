require "httparty"

module Reverb
  module Api
    class Client
      HEADERS = {
        "Content-Type" => "application/hal+json",
        "Accept" => "application/hal+json"
      }

      # url: Base URL of the Reverb API (e.g.: https://reverb.com)
      # basic_auth: optional basic auth for hitting Reverb Sandbox URLs
      def initialize(reverb_token: nil, url: "https://reverb.com", basic_auth: nil)
        @reverb_token = reverb_token
        @reverb_url = url
        @basic_auth = basic_auth
      end

      def authenticate(email, password)
        post("/api/auth/email", email: email, password: password)
      end

      def create_listing(param)
        post("/api/listings", param)
      end

      def find_listing_by_sku(sku)
        listing_attributes =  get("/api/my/listings?sku=#{URI.encode(sku)}&state=all")["listings"].first
        if listing_attributes
          Listing.new(client: self, listing_attributes: listing_attributes)
        else
          nil
        end
      end

      def post(path, params)
        handle_response HTTParty.post(url(path), with_defaults(params))
      end

      def get(path)
        handle_response HTTParty.get(url(path), default_options)
      end

      def put(path, params)
        handle_response HTTParty.put(url(path), with_defaults(params))
      end

      def delete(path, params)
        handle_response HTTParty.delete(url(path), with_defaults(params))
      end

      private

      attr_reader :basic_auth, :reverb_token, :reverb_url

      def with_defaults(params={})
        unless params.empty?
          default_options.merge(body: params.to_json)
        else
          default_options
        end
      end

      def url(path)
        File.join(reverb_url, path)
      end

      def handle_response(response)
        raise Reverb::Api::NotAuthorizedError.new(response.parsed_response["message"]) unless authorized?(response)
        response
      end

      def authorized?(response)
        !(response.code == 401 || response.code == 403)
      end

      # Tells HTTParty to parse application/hal+json as json
      # All HTTParty responses will be parsed into hashes via JSON.parse
      class HalParsingSupport < HTTParty::Parser
        SupportedFormats.merge!(
          {"application/hal+json" => :json}
        )
      end


      def default_options
        headers = HEADERS.dup

        # HTTParty really hates nil headers. It will die horribly
        # inside of net/http with no explanation.
        headers.merge!("X-Auth-Token" => reverb_token) if reverb_token

        {
          basic_auth: basic_auth,
          headers: headers,
          debug_output: $stdout,
          verify: false
        }
      end

    end
  end
end
