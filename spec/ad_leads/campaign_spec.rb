require 'spec_helper'

describe AdLeads::Client::Campaign do
  let(:client) { AdLeads::Client.new }
  let(:options) { {} }
  let(:http_success) { double(:http_success, status: 200) }

  describe '#create_complete_campaign' do
    let(:creative_opts) { {} }
    let(:ad_opts) { {} }
    let(:image_opts) { {} }
    let(:file) { './spec/fixtures/test.jpg' }
    let(:campaign_opts) { {} }
    let(:complete_campaign_opts) {{
      creative_group: creative_opts,
      ad: ad_opts,
      image: image_opts,
      file: file,
      campaign: campaign_opts
    }}

    it 'creates a creative group, ad, image, and campaign' do
      client.stub(:last_response_id) { 1 }

      expect(client).to receive(:create_creative_group).with(creative_opts)
      expect(client).to receive(:create_ad).with(1, ad_opts)
      expect(client).to receive(:create_image).with(1, 1, image_opts)
      expect(client).to receive(:upload_image).with(1, 1, 1, file)
      expect(client).to receive(:create_campaign).with(1, campaign_opts)
      client.create_complete_campaign(complete_campaign_opts)
    end
  end

  describe '#create_campaign' do
    it 'creates a campaign' do
      expect(client).to receive(:post).with('/campaigns', {creativeGroups: 1})
      client.create_campaign(1, options)
    end
  end

  describe '#update_campaign' do
    it 'updates the respective campaign' do
      expect(client).to receive(:post).with('/campaigns/1', options)
      client.update_campaign(1, options)
    end
  end

  describe '#verify_campaign' do
    it 'verifies the respective campaign' do
      expect(client).to receive(:get).with('/campaigns/1/plan')
      client.verify_campaign(1)
    end
  end

  describe '#launch_campaign' do
    it 'launches a campaign' do
      etag_response = double :response, headers: { 'Etag' => 1 }
      client.stub(:campaign_etag) { etag_response }
      expect(client).to receive(:post).with('/campaigns/1/launch', {etag: 1} )
      client.launch_campaign(1)
    end

    it 'gets etag' do
      expect(client).to receive(:get).with('/campaigns/1')
      client.send(:campaign_etag, 1)
    end

    context 'with EtagMismatchError' do
      it 'retries launch a maximum of three times' do
        etag_response = double :response, headers: { 'Etag' => 1 }
        client.stub(:campaign_etag) { etag_response }
        client.stub(:post) { raise AdLeads::EtagMismatchError.new 'Error' }
        expect(client).to receive(:post).exactly(3).times
        client.launch_campaign(1)
      end
    end
  end
end
