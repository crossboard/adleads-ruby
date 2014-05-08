require 'spec_helper'
require './spec/fixtures/deal.rb'

describe AdLeads::Client do
  let(:connection) { double(:http_connection) }
  let(:client) { AdLeads::Client.new }
  let(:config_keys) { AdLeads::Configuration::VALID_CONFIG_KEYS }
  let(:create_url) { '/api/v1/promotions'}
  let(:deal) { Deal.new }


  it 'inherits config' do
    expect(client).to respond_to(config_keys.sample)
  end

  before { Faraday.stub(:new) { connection } }

  describe '#create' do
    context 'Promotion' do
      it 'creates param structure' do
        connection.stub(:post)
        expect(AdLeads::Promotion).to receive(:promotion_params).with(deal).and_return({})
        client.create(:promotion, deal)
      end

      it 'calls post correctly' do
        params = { foo: 'bar' }
        AdLeads::Promotion.stub(:promotion_params) { params }
        expect(connection).to receive(:post).with(create_url)
        client.create(:promotion, deal)
      end
    end
  end
end
