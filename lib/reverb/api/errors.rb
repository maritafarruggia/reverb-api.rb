module Reverb
  module Api
    class NotAuthorizedError < StandardError
      def initialize(message)
        super(message || "Reverb authorization failed. Please check your X-Auth-Token header.")
      end
    end
  end
end
