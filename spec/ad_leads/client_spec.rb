require 'spec_helper'
require 'pry'

describe AdLeads::Client do
  let(:client) { AdLeads::Client.new }
  let(:connection) { client.connection }
  let(:config_keys) { AdLeads::Configuration::VALID_CONFIG_KEYS }
  let(:token) { '123' }

  before do
    client.stub(:token).and_return(token)
  end

  it 'inherits config' do
    Faraday.stub(:new) { connection }
    expect(client).to respond_to(config_keys.sample)
  end

  context 'connection' do
    let(:connection) { double(:http_connection) }

    it 'calls token' do
      expect(client).to receive(:token).and_return('xyz')
      client.send(:connection)
    end
  end

end
