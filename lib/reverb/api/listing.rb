require "hashr"

module Reverb
  module Api
    class Listing < Hashr
      def initialize(listing_attributes:, client:)
        @client = client
        super(listing_attributes)
      end

      def update(attributes)
        client.put(_links.self.href, attributes)
      end

      attr_reader :client
    end
  end
end
