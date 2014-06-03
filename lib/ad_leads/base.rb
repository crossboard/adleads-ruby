class AdLeads::Base
  attr_accessor :response

  def create!(params)
    self.response = client.post(root_path, params)
  end

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
