require 'spec_helper'

describe AdLeads::Base do
  let(:base) { AdLeads::Base.new() }

  describe '#id' do
    let(:response) { double(:response, body: '{ "data": [1] }') }
    before { base.response = response }

    it 'parses ID from JSON response body' do
      expect(base.id).to eq 1
    end
  end

  describe 'client' do
    it 'returns an instance of AdLeads::Client' do
      expect(base.client).to be_a AdLeads::Client
    end
  end
end
