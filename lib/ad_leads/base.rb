class AdLeads::Base
  attr_accessor :response

  def client
    @client ||= AdLeads::Client.new
  end

  def id
    @id ||= JSON.parse(response.body)['data'].first
  end

  def status
    response.status
  end
end
