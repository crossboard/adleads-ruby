class AdLeads::CreativeGroup < AdLeads::Base

  # params = {
  #   'name' => 'test creative group',
  #   'productName' =>  'test product',
  #   'privacyPolicyUrl' => 'http://privacy_url'
  # }

  def create!(params)
    self.response = client.post('/creativegroups', params)
  end

end
