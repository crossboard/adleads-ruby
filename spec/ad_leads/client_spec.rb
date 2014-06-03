require 'spec_helper'
require 'pry'

describe AdLeads::Client do
  let(:client) { AdLeads::Client.new }

  context 'connection' do
    let(:config_keys) { AdLeads::Configuration::VALID_CONFIG_KEYS }
    let(:token) { '3141ac1f-5f8f-4376-8006-e2241b8b9f1a' }
    before { client.stub(:token).and_return(token) }

    it 'inherits config' do
      expect(client).to respond_to(config_keys.sample)
    end

    it 'calls token' do
      expect(client).to receive(:token).and_return('xyz')
      client.send(:connection)
    end
  end
end
