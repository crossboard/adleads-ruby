require 'spec_helper'

describe AdLeads::Ad do
  let(:ad) { AdLeads::Ad.new(1) }
  let(:client) { ad.client }
  let(:params) { {} }

  it 'inherits from AdLeads::Base' do
    expect(ad.class.ancestors).to include AdLeads::Base
  end

  describe '#create!' do
    it 'posts to Ad Leads ad endpoint for creatives' do
      expect(client).to receive(:post).with('/creativegroups/1/creatives', params)
      ad.create!(params)
    end

    it 'assigns #response' do
      client.stub(:post) { 'Foobar' }
      ad.create!(params)
      expect(ad.response).to eq 'Foobar'
    end
  end

end
