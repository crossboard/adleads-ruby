class AdLeads::CreativeGroup < AdLeads::Base
  attr_accessor :params

  def initialize(params)
    @params = params
  end

  def create
    self.response = client.create_creative_group(params)
  end
end
