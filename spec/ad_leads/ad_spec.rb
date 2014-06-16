require 'spec_helper'

describe AdLeads::Client::Ad do
  let(:client) { AdLeads::Client.new }
  let(:options) { {} }

  describe '#create_ad' do
    it 'creates an ad' do
      expect(client).to receive(:post).with('/creativegroups/1/creatives', options)
      client.create_ad(1, options)
    end
  end

end
