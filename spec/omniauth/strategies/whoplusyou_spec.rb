# frozen_string_literal: true

require "spec_helper"

describe OmniAuth::Strategies::Whoplusyou do
  subject(:strategy) do
    described_class.new(app, "id", "secret", @options || {}).tap do |strategy|
      allow(strategy).to receive(:request).and_return(request)
    end
  end

  let(:app) do
    lambda do
      [200, {}, ["Hello."]]
    end
  end

  let(:request) { double("Request", params: {}, cookies: {}, env: {}) }

  before do
    OmniAuth.config.test_mode = true
  end

  after do
    OmniAuth.config.test_mode = false
  end

  describe "#client_options" do
    it "has correct site" do
      expect(strategy.options.client_options.site).to eq("https://app.whoplusyou.com")
    end

    it "allows overriding the site" do
      @options = { client_options: { "site" => "https://example.com" } }

      expect(strategy.options.client_options.site).to eq("https://example.com")
    end

    it "has correct authorize_url" do
      expect(strategy.options.client_options.authorize_url).to eq("/oauth/authorize")
    end

    it "allows overriding the authorize_url" do
      @options = { client_options: { "authorize_url" => "/foo" } }

      expect(strategy.options.client_options.authorize_url).to eq("/foo")
    end
  end

  describe "#callback_url" do
    let(:base_url) { "https://example.com" }

    it "has the correct default callback path" do
      allow(strategy).to receive(:full_host) { base_url }

      expect(strategy.send(:callback_url)).to eq("#{base_url}/auth/whoplusyou/callback")
    end

    it "sets the callback_path parameter if present" do
      @options = { callback_path: "/auth/foo/callback" }

      allow(strategy).to receive(:full_host) { base_url }

      expect(strategy.send(:callback_url)).to eq("#{base_url}/auth/foo/callback")
    end

    it "uses the redirect_uri parameter if present" do
      @options = { redirect_uri: "https://example.com/foo" }

      expect(strategy.send(:callback_url)).to eq("https://example.com/foo")
    end
  end

  describe "#info" do
    let(:access_token) { OAuth2::AccessToken.from_hash(client, { "access_token" => "a" }) }

    let(:client) do
      OAuth2::Client.new("id", "secret") do |builder|
        builder.request :url_encoded

        builder.adapter :test do |stub|
          stub.get("/api/v2/get-basic-user-info") do
            [200, { "content-type" => "application/json" }, response_hash.to_json]
          end
        end
      end
    end

    let(:response_hash) do
      {
        status: "ok",
        user_id: 1001,
        email: "sally@example.com",
        first_name: "Sally",
        last_name: "Smith",
        user_types: [
          {
            id: 1,
            type: "Job Seeker"
          },
          {
            id: 2,
            type: "Organization User"
          }
        ],
        company: {
          id: 1,
          name: "Interslice"
        }
      }
    end

    before do
      allow(strategy).to receive(:access_token).and_return(access_token)
    end

    it "returns parsed profile data" do
      expect(strategy.info).to eq({
                                    "uid" => response_hash[:user_id],
                                    "first_name" => response_hash[:first_name],
                                    "last_name" => response_hash[:last_name],
                                    "email" => response_hash[:email]
                                  })
    end
  end

  describe "#extra" do
    let(:access_token) { OAuth2::AccessToken.from_hash(client, { "access_token" => "a" }) }

    let(:client) do
      OAuth2::Client.new("id", "secret") do |builder|
        builder.request :url_encoded

        builder.adapter :test do |stub|
          stub.get("/api/v2/get-basic-user-info") do
            [200, { "content-type" => "application/json" }, response_hash.to_json]
          end
        end
      end
    end

    let(:response_hash) do
      {
        status: "ok",
        user_id: 1001,
        email: "sally@example.com",
        company: {
          id: 1,
          name: "Interslice"
        }
      }
    end

    before do
      allow(strategy).to receive(:access_token).and_return(access_token)
    end

    it "returns parsed profile data" do
      expect(strategy.extra).to eq({
                                     "raw_info" => {
                                       "company" => {
                                         "id" => 1,
                                         "name" => "Interslice"
                                       },
                                       "email" => response_hash[:email],
                                       "status" => response_hash[:status],
                                       "user_id" => response_hash[:user_id]
                                     }
                                   })
    end
  end
end
