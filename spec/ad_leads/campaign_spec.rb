require 'spec_helper'

describe AdLeads::Campaign do
  let(:campaign) { AdLeads::Campaign.new() }
  let(:client) { campaign.client }
  let(:params) { {} }
  let(:http_success) { double(:http_success, status: 200) }

  it 'inherits from AdLeads::Base' do
    expect(campaign.class.ancestors).to include AdLeads::Base
  end

  describe '#create!' do
    it 'posts to AdLeads::Campaign#root_path' do
      expect(client).to receive(:post).with('/campaigns', params)
      campaign.create!(params)
    end

    it 'assigns #response' do
      client.stub(:post) { 'Foobar' }
      campaign.create!(params)
      expect(campaign.response).to eq 'Foobar'
    end
  end

  describe '#update!' do
    before { campaign.instance_variable_set(:@id, 1) }

    it 'posts to AdLeads::Campaign#campaign_path' do
      expect(client).to receive(:post).with('/campaigns/1', params)
      campaign.update!(params)
    end
  end

  describe '#verify!' do
    before { campaign.instance_variable_set(:@id, 1) }

    it 'sends a GET request to AdLeads::Campaign#verify_campaign_path' do
      expect(client).to receive(:get).with('/campaigns/1/plan')
      campaign.verify!
    end
  end

  describe '#launch!' do
    before do
      campaign.stub(:id) { 1 }
      campaign.stub(:etag) { 'Fake etag' }
    end

    it 'posts to AdLeads::Campaign#launch_campaign_path' do
      expect(client).to receive(:post).with('/campaigns/1/launch', { etag: 'Fake etag'}).and_return(http_success)
      campaign.launch!
    end

    it 'uses #with_etag block' do
      client.stub(:post)
      expect(campaign).to receive(:with_etag)
      campaign.launch!
    end
  end

  describe '#etag_path' do
    before { campaign.instance_variable_set(:@id, 1) }

    it 'is an alias for #campaign_path' do
      expect(campaign.etag_path).to eq campaign.campaign_path
    end
  end
end
