require 'spec_helper'

describe AdLeads::Image do
  let(:image) { AdLeads::Image.new( {creative_group_id: 1, ad_id: 1} ) }
  let(:client) { image.client }
  let(:params) { {} }

  it 'inherits from AdLeads::Base' do
    expect(image.class.ancestors).to include AdLeads::Base
  end

  describe '#create!' do
    it 'posts to AdLeads::Image endpoint' do
      expect(client).to receive(:post).with('/creativegroups/1/creatives/1/images', params)
      image.create!(params)
    end

    it 'assigns #response' do
      client.stub(:post) { 'Foobar' }
      image.create!(params)
      expect(image.response).to eq 'Foobar'
    end
  end

  describe '#upload!' do
    let(:file) { './spec/fixtures/test.jpg' }
    before { image.stub(:etag) { 'Fake etag' } }

    xit 'posts to AdLeads::Image#image_upload_path' do
      expect(client).to receive(:post).with('/creativegroups/1/creatives/1/images', params) # fix
      image.upload!(file)
    end
  end
end
