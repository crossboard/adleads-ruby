require 'spec_helper'

describe AdLeads::Token do
  let(:config_keys) { AdLeads::Configuration::VALID_CONFIG_KEYS }
  let(:token) { AdLeads::Token.new }

  it 'inherits config' do
    expect(token).to respond_to(config_keys.sample)
  end

  describe '#assertion' do
    let(:claims) {{
      iss: token.client_id,
      aud: token.endpoint,
      prn: token.principle,
      scope: 'campaign_read,campaign_write,reports',
      exp: Time.now.utc.to_i + (5*60)
    }}
    let(:private_key) { 'Foobar' }
    before { token.stub(:private_key) { private_key } }

    it 'JWT should receive encode with correct params' do
      expect(JWT).to receive(:encode).with(claims, private_key, 'RS256')
      token.assertion
    end
  end

  describe '#private_key' do
    let(:file) { double(:private_key_mock) }
    before { File.stub(:read) { file } }

    it 'RSA should initialize with new file' do
      expect(OpenSSL::PKey::RSA).to receive(:new).with(file)
      token.private_key
    end

    it 'should memoize the result' do
      token.instance_variable_set(:@private_key, 'Foobar')
      expect(OpenSSL::PKey::RSA).not_to receive(:new).with(file)
      token.private_key
    end
  end

  describe '#token' do
    context '@token is set' do
      it 'returns @token' do
        token.instance_variable_set(:@token, 'Foobar')
        expect(token.token).to eq 'Foobar'
      end
    end

    context '@token is not set' do
      let(:response) { double(:response_mock, body: '{ "access_token": "Foobar" }') }

      it 'connection should receive post' do
        expect(token.connection).to receive(:post).with('/oauth/token') { response }
        token.token
      end

      it 'assigns token from response' do
        token.connection.stub(:post) { response }
        expect(token.token).to eq 'Foobar'
      end
    end
  end

  describe '#token_request_params' do
    let(:assertion) { 'Foobar' }
    before { token.stub(:assertion) { assertion } }

    it 'is valid' do
      expect(token.token_request_params).to eq({
        grant_type: 'jwt-bearer',
        assertion: assertion
      })
    end
  end

  it 'uses AdLeads::Client.connection'
end
