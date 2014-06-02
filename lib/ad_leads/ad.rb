class AdLeads::Ad < AdLeads::Base
  attr_accessor :params, :creative_group_id

  def initialize(params, creative_group_id)
    @params = params
    @creative_group_id = creative_group_id
  end

  def create
    self.response = client.create_ad(params, creative_group_id)
  end

end
