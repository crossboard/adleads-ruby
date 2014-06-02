class AdLeads::Image < AdLeads::Base
  attr_accessor :params, :creative_group_id, :ad_id

  def initialize(opts)
    @params = opts[:params]
    @creative_group_id = opts[:creative_group_id]
    @ad_id = opts[:ad_id]
  end

  def create
    self.response = client.create_content_holder(ids, params)
  end

  def ids
    { group: creative_group_id, creative: ad_id }
  end

  def upload_file(file)
    client.upload_image(ids, etag, file)
  end

  def etag_path
    [
      'creativegroups',
      creative_group_id,
      'creatives',
      ad_id,
      'images',
      id
    ].join('/')
  end

  def etag
    request(:get, etag_path)
  end
end

# module AdLeads
#   class Image
#     attr_accessor :etag, :retry_count, :campaign_id

#     def initialize(image_id)
#       @campaign_id = Campaign.id
#       @id = id
#       @etag = Client.get_content_etag
#       @retry_count = 0
#     end

#     def upload
#       post(Campaign., self.etag)
#     rescue ETAG MISMATCH
#       refresh_etag
#       @retry_count += 1
#       while @retry_count < 10
#         retry
#       end
#     end

#     def refresh_etag
#       response = get(ETAG_PATH, self.id)
#       @etag = response.headers['ETag']
#     end
#   end
# end
