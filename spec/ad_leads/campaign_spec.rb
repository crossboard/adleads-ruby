require 'spec_helper'

describe AdLeads::Campaign do
  let(:campaign) { AdLeads::Campaign.new() }
  let(:client) { campaign.client }
  let(:params) { {} }

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

    it 'assigns #response'
  end

  describe '#verify!' do
    before { campaign.instance_variable_set(:@id, 1) }

    it 'sends a GET request to AdLeads::Campaign#verify_campaign_path' do
      expect(client).to receive(:get).with('/campaigns/1/plan')
      campaign.verify!
    end

    it 'assigns #response'
  end

  describe '#launch!' do
    before { campaign.instance_variable_set(:@id, 1) }
    before { campaign.stub(:etag) { 'Fake etag' } }

    it 'posts to AdLeads::Campaign#launch_campaign_path' do
      expect(client).to receive(:post).with('/campaigns/1/launch', { etag: 'Fake etag'})
      campaign.launch!
    end

    it 'assigns #response'
  end

  describe '#etag_path' do
    before { campaign.instance_variable_set(:@id, 1) }

    it 'is an alias for #campaign_path' do
      expect(campaign.etag_path).to eq campaign.campaign_path
    end
  end
end
