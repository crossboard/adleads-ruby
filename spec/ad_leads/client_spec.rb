require 'spec_helper'
require 'pry'

describe AdLeads::Client do
  let(:client) { AdLeads::Client.new }

  context 'connection' do
    let(:config_keys) { AdLeads::Configuration::VALID_CONFIG_KEYS }
    let(:token) { '2f7622c3-da63-42e9-a3d8-4275f70f1f79' }
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
