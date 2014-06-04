require 'spec_helper'

describe AdLeads::Token do
  let(:config_keys) { AdLeads::Configuration::VALID_CONFIG_KEYS }
  let(:token) { AdLeads::Token.new }
  let(:private_key) { <<-PRIVATE_KEY }
-----BEGIN RSA PRIVATE KEY-----
MIICXAIBAAKBgQCOcCBGAtoZrwaN068x87WjW0x7GcYh5hXRN7I5Ib30MqT/jz9X
AzX9WTg5Cqm+2EYSxlOi+Inoqoz1fILKGuxVnC+R7bWNrRTPWzzd4mAsfUw1Sr7c
h9055f0l5BgdBZ4QAoa/9p7avZhKmX+x3pyLZ6EzMXbALoJsQGojmfzotwIDAQAB
AoGAQlNZ49/uGSmUHrSkjtkSCng3+9Z7mUtfe2W4+ruIjU6L4GiesPDQ0iEaeg1K
D5D7yEBLr8aVyR6ptqH88QlqZJzWtOwA39+9o/HyR9tl9Py7CpMYAUIqTqLHds0r
E662oal2A2EZER0iJY3qFAbW8TlGtLSFb4vwvcQmIWl2Q/kCQQDJe9DGN5bySzgD
uD8v091Q0tDDCWG/zYkTcMT2Ii2K6tqd4AlYHaJ3wtgOhvFIbOfMqyk2YBgmfRVf
DNV4OHdtAkEAtPpj0sJB/Q3tv+ftgzqGIZOygs4UtsRtqUh96nJiUsIrxT4BkD+e
LYeCkJytfHMZ3CR0ReGuRPiiAtQAZYjWMwJBAKiZtH16HRUJvojWUAG8v3EXyFu8
6RAwdSlQb3Er7oJVvrTnucoDmmWvJU8auqOJhnstK2J2DR+AAjc0rRlZ3w0CQEmx
+Ho3TmW8iUbvK6GXcE019qgbQQYXwMwBT/zrLSykEuzTzhEuRrwlhT5b/q1BtZMW
aR6Xwr4lPNvH9o1iBk8CQHdh405KMMAZZOsXccXqpgxUl90lTpM0p+cQERLGHmtR
OAQfFNhtZpgvPM/VALKb/RfJ7dWJzT9OMnVgtDyNsD8=
-----END RSA PRIVATE KEY-----
PRIVATE_KEY
  let(:rsa_key) {
    OpenSSL::PKey::RSA.new private_key
  }

  before { token.stub(:private_key) { private_key } }

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

    it 'JWT should receive encode with correct params' do
      expect(JWT).to receive(:encode).with(claims, an_instance_of(OpenSSL::PKey::RSA), 'RS256')
      token.assertion
    end
  end

  describe '#rsa_key' do
    it 'RSA should initialize with new file' do
      expect(OpenSSL::PKey::RSA).to receive(:new).with private_key
      token.rsa_key
    end

    it 'should memoize the result' do
      token.instance_variable_set(:@rsa_key, 'Foobar')
      expect(OpenSSL::PKey::RSA).not_to receive(:new).with private_key
      token.rsa_key
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
