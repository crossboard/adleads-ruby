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
    create_creative_group(ad_campaign_obj)
    create_ad(ad_campaign_obj)
    create_content_holder(ad_campaign_obj)
    get_content_etag
    upload_image(ad_campaign_obj)
    create_campaign(ad_campaign_obj)
    verify_campaign
    get_campaign_etag
    configure_campaign_signups
    launch_campaign
  end

  def create_creative_group(ad_campaign_obj)
    params = {
      'name' => ad_campaign_obj[:campaign_info][:name],
      'productName' => ad_campaign_obj[:content_info][:name],
      'privacyPolicyUrl' => ad_campaign_obj[:]
    }

    response = post('/creativegroups', params)
    @creative_group_id = JSON.parse(response.body)["data"]
  end

  def create_ad(type)
    response = post("/creativegroups/#{@creative_group_id}/creatives", type)
    @creatives_id = JSON.parse(response.body)["data"]
  end

  def create_content_holder(type)
    path = "/creativegroups/#@create_group_id/creatives/#{@creatives_id}/images"
    response = post(path, type)
    @image_id = JSON.parse(response.body)["data"]
  end

  def get_content_etag
    reponse = get("/creativegroups/#{@creative_group_id}/creatives/#{@creatives_id}/images/#{@image_id}")
    @image_etag = response.headers['ETag']
  end

  def upload_image(file_name)
    path = "/creativegroups/#{@creative_group_id}/creatives/#{@creatives_id}/images/#{@image_id}/file"
    image_payload = {
      file: Faraday::UploadIO.new(file, 'image/jpeg')
    }
    connection_with_etag_match(@image_etag).post(path, image_payload)
  end

  def create_campaign(params)
    response = post('/campaigns', params)
    @campaign_id = JSON.parse(response.body)["data"]
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
