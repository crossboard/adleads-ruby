class AdLeads::Base
  attr_accessor :response

  def id
    JSON.parse(response.body)['data'].first
  end

  def status
    response.status
  end
end
