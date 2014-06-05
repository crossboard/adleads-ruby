class AdLeads::Image < AdLeads::Base
  include AdLeads::Etag
  attr_accessor :creative_group_id, :ad_id

  def initialize(opts)
    @creative_group_id = opts[:creative_group_id]
    @ad_id = opts[:ad_id]
  end

  def ids
    { group: creative_group_id, creative: ad_id }
  end

  def upload!(file)
    with_etag do
      client.post(image_upload_path, image_upload_params(file))
    end
  end

  def image_upload_params(file)
    {
      file: Faraday::UploadIO.new(file, 'image/jpeg'),
      etag: etag
    }
  end

  def image_upload_path
    [
      root_path,
      id,
      'file'
    ].join('/')
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
