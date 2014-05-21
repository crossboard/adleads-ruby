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
      get_campaign_etag
      launch_campaign
    end

    def process_response(response)
      JSON.parse(response.body)["data"].to_s.gsub(/[^0-9a-z]/i, '')
    end

    def create_creative_group
      response = post('/creativegroups', cg_params)
      @creative_group_id = process_response(response)
    end

    def create_ad
      response = post("/creativegroups/#{@creative_group_id}/creatives", ad_params)
      @creatives_id = process_response(response)
    end
    #in gem
    def create_content_holder
      path = "/creativegroups/#@creative_group_id/creatives/#{@creatives_id}/images"
      response = post(path, content_holder_params)
      @image_id = process_response(response)
    end

    def get_content_etag
      path = "/creativegroups/#@creative_group_id/creatives/#{@creatives_id}/images/#{@image_id}"
      response = get(path)
      @image_etag = response.headers['ETag']
    end
    #in gem
    def upload_image
      file = @ad_campaign_obj[:content_info][:file]
      path = "/creativegroups/#{@creative_group_id}/creatives/#{@creatives_id}/images/#{@image_id}/file"
      image_payload = {
        file: Faraday::UploadIO.new(file, 'image/jpeg')
      }
      connection_with_etag_match(@image_etag).post(path, image_payload)
    end

    def create_campaign
      response = post('/campaigns', campaign_params)
      @campaign_id = process_response(response)
    end

    def get_campaign_etag
      path = "/campaigns/#{@campaign_id}"
      response = get(path)
      @campaign_etag = response.headers['ETag']
    end

    def configure_campaign_signups
      path = "/campaigns/#{@campaign_id}/signupdelivery"
      connection_with_etag_match(@campaign_etag).send(:post, path) do |request|
        request.body = signup_params
      end
    end

    def launch_campaign
      path = "/campaigns/#{@campaign_id}/launch"
      reponse = connection_with_etag_match(@campaign_etag).send(:post, path)
    end

    def verify_campaign
      response = get("/campaigns/#{@campaign_id}/plan")
    end

    def get(path, params = {})
      request(:get, path, params)
    end

    def post(path, params = {})
      request(:post, path, params)
    end

    private

    def cg_params
      {
        'name' => @ad_campaign_obj[:campaign_info][:name],
        'productName' => @ad_campaign_obj[:content_info][:name],
        'active' => @ad_campaign_obj[:content_info][:active],
        'privacyPolicyUrl' => @ad_campaign_obj[:content_info][:privacy]
      }
    end

    def ad_params
      {
        'name' => @ad_campaign_obj[:content_info][:name],
        'type' => @ad_campaign_obj[:content_info][:type],
        ##mobile
        'headerText' => @ad_campaign_obj[:content_info][:headerText],
        'bodyText' => @ad_campaign_obj[:content_info][:bodyText],
        ##email
        'fromAddress' => @ad_campaign_obj[:campaign_info][:email],
        'subject' => @ad_campaign_obj[:content_info][:subject],
        'companyName' => @ad_campaign_obj[:campaign_info][:dba],
        'mailingAddress' => @ad_campaign_obj[:campaign_info][:address],
        'calltoAction' => @ad_campaign_obj[:campaign_info][:cta],
        'preHeader' => @ad_campaign_obj[:campaign_info][:pre_header]
      }
    end

    def content_holder_params
      {
        'type' => @ad_campaign_obj[:content_info][:image_type]
      }
    end

    def campaign_params
      {
        'name' => @ad_campaign_obj[:content_info][:name],
        'verticals' =>  @ad_campaign_obj[:content_info][:verticals],
        'offerIncentiveCategory' => @ad_campaign_obj[:content_info][:incentives],
        'collectedFields' => @ad_campaign_obj[:content_info][:collected_fields],
        'budget' => @ad_campaign_obj[:campaign_info][:spend],
        'creativeGroups' => @creative_group_id
      }
    end

    def signup_params
      {
        'dataSink' => 'RealtimeHTTP',
        'method' => 'POST',
        'url' => BTL_URL
      }
    end

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
