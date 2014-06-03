require 'spec_helper'

describe AdLeads::Image do
  let(:image) { AdLeads::Image.new( {creative_group_id: 1, ad_id: 1} ) }
  let(:client) { image.client }
  let(:params) { {} }
  let(:bad_etag_response) { double(:http_response, status: 412) }
  let(:http_success) { double(:http_response, status: 200) }

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

    it 'posts to AdLeads::Image#image_upload_path' do
      image.stub(:image_upload_params) {{}}
      expect(client).to receive(:post).
        with('/creativegroups/1/creatives/1/images/file', params).
        and_return(http_success)
      image.upload!(file)
    end

    describe 'with bad etag' do
      before { image.stub(:id) { 1 } }

      it 'retries post' do
        expect(client).to receive(:post).once.and_return(bad_etag_response)
        expect(image).to receive(:refresh_etag!).and_return(1)
        expect(client).to receive(:post).once.and_return(http_success)
        image.upload!(file)
      end

      it 'tries only 3 times' do
        expect(client).to receive(:post).and_return(bad_etag_response).exactly(3).times
        image.stub(:refresh_etag!) { 1 }
        image.upload!(file)
      end
    end
  end
end
