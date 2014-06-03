require 'faraday'
require 'json'

module  AdLeads
  class Client
    attr_accessor *Configuration::VALID_CONFIG_KEYS

    def initialize(options={})
      merged_options = AdLeads.options.merge(options)
      Configuration::VALID_CONFIG_KEYS.each do |key|
        send("#{key}=", merged_options[key])
      end
    end

    def configure_campaign_signups(ad_campaign_id, etag, params = {})
      path = "/campaigns/#{ad_campaign_id}/signupdelivery"
      request(:post, path, params.merge(etag: etag))
    end

    def get_campaign_etag(ad_campaign_id)
      response = get("/campaigns/#{ad_campaign_id}")
      response.headers['ETag']
    end

    def get_campaign_status(ad_campaign_id)
      response = get("/campaigns/#{ad_campaign_id}")
      JSON.parse(response.body)['status']
    end

    def get_content_etag(ids)
      get("/creativegroups/#{ids[:group]}/creatives/#{ids[:creative]}/images/#{ids[:image]}")
    end

    def get_reports(params)
      get("/reports/campaign/report", params)
    end

    def pause_campaign(ad_campaign_id, etag)
      path = "/campaigns/#{ad_campaign_id}/pause"
      request(:post, path, etag: etag)
    end

    def get(path, params = {})
      request(:get, path, params)
    end

    def post(path, params = {})
      request(:post, path, params)
    end

    private

    def etag_opts(etag)
      {
        headers: { 'If-Match' => etag },
        multipart: true
      }
    end

    def connection(opts = {})
      opts[:headers] ||= { 'Accept' => 'application/json' }

      Faraday.new(url: endpoint) do |faraday|
        faraday.headers = opts[:headers]
        faraday.request :multipart if opts[:multipart]

        faraday.authorization :Bearer, token
        faraday.adapter  :httpclient
        faraday.request :url_encoded
      end
    end

    def token
      @token ||= AdLeads::Token.new(client_id: client_id, principle: principle).token
    end

    def request(method, path, params = {})
      etag = params.delete(:etag)
      opts = etag ? etag_opts(etag) : {}

      response = connection(opts).send(method, path) do |request|
        request.params = params if method == :get
        request.body = params if method == :post
      end

      # rescue Faraday::Error::TimeoutError, Timeout::Error => error
      # rescue Faraday::Error::ClientError, JSON::ParserError => error
    end

  end
end
