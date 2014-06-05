require 'spec_helper'

# TODO: Extract Etag specs!

describe AdLeads::Image do
  let(:image) { AdLeads::Image.new( {creative_group_id: 1, ad_id: 1} ) }
  let(:client) { image.client }
  let(:params) { {} }
  let(:success) { double(:http_response, status: 200) }
  let(:etag_mismatch) { double(:http_response, status: 412) }
  let(:new_etag) { double(:http_response, status: 200, headers: { 'Etag' => '123'} ) }

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

  describe '#refresh_etag' do
    before { image.stub(:etag_path) { '/foo' } }
    it 'sets @etag from response headers' do
      expect(client).to receive(:get).with('/foo').and_return(new_etag)
      image.refresh_etag!
      expect(image.etag).to eq '123'
    end
  end

  describe '#upload!' do
    let(:file) { './spec/fixtures/test.jpg' }
    before do
      image.stub(:etag) { 'Fake etag' }
      image.stub(:id) { 1 }
    end

    it 'posts to AdLeads::Image#image_upload_path' do
      image.stub(:image_upload_params) {{}}
      expect(client).to receive(:post).
        with('/creativegroups/1/creatives/1/images/1/file', params).
        and_return(success)
      image.upload!(file)
    end

    context 'with Etag mismatch' do
      it 'retries post' do
        expect(client).to receive(:post).once.and_return(etag_mismatch)
        expect(image).to receive(:refresh_etag!).and_return(1)
        expect(client).to receive(:post).once.and_return(success)
        image.upload!(file)
      end

      it 'raises EtagMismatchError' do
        client.stub(:post) { etag_mismatch }
        client.stub(:get) { new_etag }
        expect {
          image.upload!(file)
        }.to raise_error AdLeads::Etag::MismatchError
      end
    end
  end
end
