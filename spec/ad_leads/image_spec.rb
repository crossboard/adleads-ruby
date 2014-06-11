require 'spec_helper'

describe AdLeads::Client::Image do
  let(:client) { AdLeads::Client.new }
  let(:options) { {} }
  let(:file) { './spec/fixtures/test.jpg' }

  describe '#create_image' do
    it 'creates an image' do
      expect(client).to receive(:post).
        with('/creativegroups/1/creatives/1/images', options)
      client.create_image(1, 1, options)
    end
  end

  describe '#upload_image' do
    it 'uploads an image' do
      client.stub(:image_upload_opts) { {} }
      expect(client).to receive(:post).
        with('/creativegroups/1/creatives/1/images/1/file', options)
      client.upload_image(1, 1, 1, file)
    end

    it 'gets etag' do
      etag_response = double :response, headers: { 'Etag' => 1 }
      expect(client).to receive(:get).with('/creativegroups/1/creatives/1/images/1').
        and_return(etag_response)
      client.send(:image_upload_opts, 1, 1, 1, file)
    end

    context 'with EtagMismatchError' do
      it 'retries upload a maximum of three times' do
        client.stub(:image_upload_opts) { {} }
        client.stub(:post) { raise AdLeads::EtagMismatchError.new 'Error' }
        expect(client).to receive(:post).exactly(3).times
        client.upload_image(1, 1, 1, file)
      end
    end
  end
end
