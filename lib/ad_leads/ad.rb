class AdLeads::Ad < AdLeads::Base
  # params = {
  #         'type' => 'Mobile',
  #         'name' =>  'test mobile ad',
  #         'headerText' => 'get your ad on this phone today',
  #         'bodyText' => 'this is mobile ad body copy'
  #       }

  attr_accessor :creative_group_id

  def initialize(creative_group_id)
    @creative_group_id = creative_group_id
  end

  def create!(params)
    self.response = client.post("/creativegroups/#{creative_group_id}/creatives", params)
  end

end
