require 'spec_helper'
require 'pry'

describe AdLeads::Client do
  let(:client) { AdLeads::Client.new }

  context 'stubbed connection' do
    let(:connection) { double(:http_connection) }
    before { Faraday.stub(:new) { connection } }

    describe '#request with etag mismatch' do
      it 'retries' do
        expect(connection).to receive(:post).once.and_return(double(:http_response, status: 412))
        expect(connection).to receive(:post).once.and_return(double(:http_response, status: 200))
        client.pause_campaign(12, 132)
        # what do we need and where are we going to get it from
      end
    end
  end

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

  describe '#get_etag' do
    let(:response) { double(:http_response, headers: { "ETag" => 'foobar'}) }
    it 'returns etag' do
      client.stub(:request) { response }
      expect(client.get_etag).to eq 'foobar'
    end

    context 'for image etags' do
      let(:etag_path) { '/creativegroups/1/creatives/1/images/1' }
      it 'gets the image path' do
        expect(client).to receive(:request).with(:get, etag_path).and_return( response )
        client.get_etag('/images/')

      end
    end

    context 'for campaign etags' do
      it 'gets the campaign path' do
      end
    end
  end
end
