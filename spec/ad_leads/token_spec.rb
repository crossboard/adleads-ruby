require 'spec_helper'

describe AdLeads::Token do
  let(:config_keys) { AdLeads::Configuration::VALID_CONFIG_KEYS }
  let(:token) { AdLeads::Token.new }

  it 'inherits config' do
    expect(token).to respond_to(config_keys.sample)
  end

end
