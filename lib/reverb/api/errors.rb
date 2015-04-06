module Reverb
  module Api
    class NotAuthorizedError < StandardError
      def initialize(reverb_response)
        message = set_message(reverb_response)
        super(message)
      end

      private

      def set_message(response)
        response.parsed_response["message"] || "Reverb authorization failed. Please check your X-Auth-Token header."
      end
    end
  end
end
