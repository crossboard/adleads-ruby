require 'spec_helper'
require 'pry'

describe AdLeads::Client do
  let(:client) { AdLeads::Client.new }
  let(:connection) { double(:faraday_connection) }
  let(:token) { '2f7622c3-da63-42e9-a3d8-4275f70f1f79' }
  let(:status) { 200 }
  let(:response) { double(:http_response, status: status, body: {}, headers: {}) }

  before { client.stub(:token) { token } }

  it { should respond_to(:last_response) }

  describe '#connection' do
    let(:config_keys) { AdLeads::Configuration::VALID_CONFIG_KEYS }

    it 'inherits config' do
      expect(client).to respond_to(config_keys.sample)
    end

    it 'calls token' do
      expect(client).to receive(:token).and_return('xyz')
      client.send(:connection)
    end
  end

  describe '#request' do
    before do
      Faraday.stub(:new) { connection }
      connection.stub(:post) { response }
    end

    context 'status: 200' do
      let(:status) { 200 }
      it 'sets @last_response' do
        client.post('foo')
        expect(client.instance_variable_get(:@last_response)).to eq response
      end
    end

    context 'status: 412' do
      let(:status) { 412 }
      it 'raises AdLeads::EtagMismatchError' do
        expect {
          client.post('foo')
        }.to raise_error AdLeads::EtagMismatchError
      end
    end

    context 'status: 500' do
      let(:status) { 500 }
      it 'raises AdLeads::ApiError' do
        expect {
          client.post('foo')
        }.to raise_error AdLeads::ApiError
      end
    end
    context 'status: 401' do
      let(:status) { 401 }
      it 'raises AdLeads::ApiError' do
        expect {
          client.post('foo')
        }.to raise_error AdLeads::AuthError
      end
    end
  end

  describe '#last_response_id' do
    let(:last_response) { double :response, body: {'data' => [88]}.to_json }

    it 'retrieves id from @last_response' do
      client.stub(:last_response) { last_response }
      expect(client.last_response_id).to eq 88
    end
  end
end
