require 'faraday'
require 'json'
require 'pry'

module AdLeads
  class Campaign
    attr_accessor :creative_group_id, :creatives_id, :image_id, :image_etag, :campaign_id, :campaign_etag

    attr_accessor *Configuration::VALID_CONFIG_KEYS

    BTL_URL = 'www.myurl.com'
    def initialize(options={})
      merged_options = AdLeads.options.merge(options)
      Configuration::VALID_CONFIG_KEYS.each do |key|
        send("#{key}=", merged_options[key])
      end
    end

    def campaign_kickoff(ad_campaign_obj)
      @ad_campaign_obj = ad_campaign_obj
      create_creative_group
      create_ad
      create_content_holder
      get_content_etag
      upload_image
      create_campaign
      verify_campaign
      get_campaign_etag
      configure_campaign_signups
      launch_campaign
    end

    def process_response(response)
      JSON.parse(response.body)["data"].to_s.gsub(/[^0-9a-z]/i, '')
    end

    def create_creative_group
      params = {
        'name' => @ad_campaign_obj[:campaign_info][:name],
        'productName' => @ad_campaign_obj[:content_info][:name],
        'privacyPolicyUrl' => @ad_campaign_obj[:content_info][:privacy]
      }
      response = post('/creativegroups', params)
      @creative_group_id = process_response(response)
    end

    def create_ad
      params = {
        'type' => @ad_campaign_obj[:content_info][:type]
      }
      response = post("/creativegroups/#{@creative_group_id}/creatives", params)
      @creatives_id = process_response(response)
    end

    def create_content_holder
      params = {
        'type' => @ad_campaign_obj[:content_info][:image_type]
      }
      path = "/creativegroups/#@creative_group_id/creatives/#{@creatives_id}/images"
      response = post(path, params)
      @image_id = process_response(response)
    end

    def get_content_etag
      response = get("/creativegroups/#{@creative_group_id}/creatives/#{@creatives_id}/images/#{@image_id}")
      @image_etag = response.headers['ETag']
    end

    def upload_image
      file = @ad_campaign_obj[:content_info][:file]
      path = "/creativegroups/#{@creative_group_id}/creatives/#{@creatives_id}/images/#{@image_id}/file"
      image_payload = {
        file: Faraday::UploadIO.new(file, 'image/jpeg')
      }
      binding.pry
      connection_with_etag_match(@image_etag).post(path, image_payload)
    end

    def create_campaign
      response = post('/campaigns', params)
      @campaign_id = process_response(response)
    end

    def get_campaign_etag
      response = get("/campaigns/#{ad_campaign_id}")
      @campaign_etag = response.headers['ETag']
    end

    def configure_campaign_signups
      params = {
        'dataSink' => 'RealtimeHTTP',
        'method' => 'POST',
        'url' => BTL_URL
      }
      path = "/campaigns/#{@campaign_id}/signupdelivery"
      connection_with_etag_match(@campaign_etag).send(:post, path) do |request|
        request.body = params
      end
    end

    def launch_campaign
      path = "/campaigns/#{@campaign_id}/launch"
      connection_with_etag_match(@campaign_etag).send(:post, path)
    end

    def get(path, params = {})
      request(:get, path, params)
    end

    def post(path, params = {})
      request(:post, path, params)
    end

    private
    def connection
      @connection ||= Faraday.new(url: endpoint) do |faraday|
        faraday.headers['Accept'] = 'application/json'
        faraday.request  :url_encoded
        faraday.authorization :Bearer, token
        faraday.adapter  :httpclient  # make requests with Net::HTTP
        faraday.request :url_encoded
      end
    end

    def token
      @token ||= AdLeads::Token.new(client_id: client_id, principle: principle).token
    end

    def connection_with_etag_match(etag)
      Faraday.new(:url => endpoint) do |faraday|
        faraday.headers['If-Match'] = etag
        faraday.request  :multipart
        faraday.request  :url_encoded
        faraday.authorization :Bearer, token
        faraday.adapter  :net_http
      end
    end

    def request(method, path, params = {})
      connection.send(method, path) do |request|
        request.params = params if method == :get
        request.body = params if method == :post
      end
      # rescue Faraday::Error::TimeoutError, Timeout::Error => error
      # rescue Faraday::Error::ClientError, JSON::ParserError => error
    end
  end
end
