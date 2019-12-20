# frozen_string_literal: true

module CommonPlatformConnection
  extend ActiveSupport::Concern

  included do
    private

    def common_platform_connection
      @common_platform_connection ||= Faraday.new Rails.configuration.x.common_platform_url do |connection|
        connection.token_auth(ENV.fetch('COMMON_PLATFORM_SHARED_SECRET_KEY'))
        connection.request :json
        connection.response :json, content_type: 'application/json'
        connection.adapter Faraday.default_adapter
      end
    end
  end
end
