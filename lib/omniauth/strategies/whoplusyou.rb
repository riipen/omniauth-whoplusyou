# frozen_string_literal: true

require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Whoplusyou < OmniAuth::Strategies::OAuth2
      option :client_options, {
        site: "https://app.whoplusyou.com",
        authorize_url: "/oauth/authorize"
      }

      uid { raw_info["user_id"] }

      info do
        {
          "uid" => raw_info["user_id"],
          "first_name" => raw_info["first_name"],
          "last_name" => raw_info["last_name"],
          "email" => raw_info["email"]
        }
      end

      extra do
        { "raw_info" => raw_info }
      end

      def callback_url
        options[:redirect_uri] || (full_host + callback_path)
      end

      def raw_info
        @raw_info ||= access_token.get("/api/v2/get-basic-user-info").parsed
      end
    end
  end
end

OmniAuth.config.add_camelization "whoplusyou", "Whoplusyou"
