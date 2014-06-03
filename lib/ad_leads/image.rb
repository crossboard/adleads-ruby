class AdLeads::Image < AdLeads::Base
  include AdLeads::Etag
  attr_accessor :creative_group_id, :ad_id

  def initialize(opts)
    @creative_group_id = opts[:creative_group_id]
    @ad_id = opts[:ad_id]
  end

  def create!(params)
    self.response = client.post(root_path, params)
  end

  def ids
    { group: creative_group_id, creative: ad_id }
  end

  def upload!(file)
    params = {
      file: Faraday::UploadIO.new(file, 'image/jpeg'),
      etag: etag
    }
    client.post(image_upload_path, params)
  end

  def image_upload_path
    root_path + '/file'
  end

  def etag_path
    root_path + "/#{id}"
  end

  def root_path
    [
      '/creativegroups',
      creative_group_id,
      'creatives',
      ad_id,
      'images'
    ].join('/')
  end
end
