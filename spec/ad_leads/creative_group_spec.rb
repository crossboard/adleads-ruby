require 'spec_helper'

describe AdLeads::CreativeGroup do
  let(:creative_group) { AdLeads::CreativeGroup.new }
  let(:client) { creative_group.client }
  let(:params) {{}}

  it 'inherits from AdLeads::Base' do
    expect(creative_group.class.ancestors).to include AdLeads::Base
  end

  describe '#create!' do
    it 'posts to /creativegroups path' do
      expect(client).to receive(:post).with('/creativegroups', params)
      creative_group.create!(params)
    end

    it 'assigns #response' do
      client.stub(:post) { 'Foobar' }
      creative_group.create!(params)
      expect(creative_group.response).to eq 'Foobar'
    end
  end

end
