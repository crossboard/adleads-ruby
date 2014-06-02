class AdLeads::Campaign < AdLeads::Base
  include AdLeads::Etag

  def create!(params)
    client.create_campaign(params)
  end

  def update(params)
    client.update_campaign(id, params)
  end

  def verify!
    client.verify_campaign(id)
  end

  def launch!
    client.launch_campaign(id, etag)
  end

  def etag_path
    ['campaigns', id].join('/')
  end
end
