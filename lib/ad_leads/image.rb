module AdLeads
  class Image
    attr_accessor :etag, :retry_count, :campaign_id

    def initialize(image_id)
      @campaign_id = Campaign.id
      @id = id
      @etag = Client.get_content_etag
      @retry_count = 0
    end

    def upload
      post(Campaign., self.etag)
    rescue ETAG MISMATCH
      refresh_etag
      @retry_count += 1
      while @retry_count < 10
        retry
      end
    end

    def refresh_etag
      response = get(ETAG_PATH, self.id)
      @etag = response.headers['ETag']
    end
  end
end

