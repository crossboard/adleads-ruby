require 'spec_helper'

describe AdLeads::Client::CreativeGroup do
  let(:client) { AdLeads::Client.new }
  let(:options) {{}}

  describe '#create_creative_group' do
    it 'creates a creative group' do
      expect(client).to receive(:post).with('/creativegroups', options)
      client.create_creative_group(options)
    end
  end

end
