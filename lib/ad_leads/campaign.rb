class AdLeads::Campaign < AdLeads::Base
  include AdLeads::Etag

  # params = {
  #   'name' => 'test',
  #   'verticals' =>  82,
  #   'offerIncentiveCategory' => 5,
  #   'collectedFields' => 'firstname,lastname,email,companyname',
  #   'budget' => 50,
  #   'creativeGroups' => creative_group.id
  # }

  def update!(params)
    client.post(campaign_path, params)
  end

  def verify!
    client.get(verify_campaign_path)
  end

  def launch!
    with_etag do
      client.post(launch_campaign_path, etag: etag)
    end
  end

  def campaign_path
    root_path + "/#{id}"
  end
  alias :etag_path :campaign_path

  def launch_campaign_path
    campaign_path + '/launch'
  end

  def root_path
    '/campaigns'
  end

  def verify_campaign_path
    campaign_path + '/plan'
  end
end
