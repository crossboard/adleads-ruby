require 'spec_helper'

describe AdLeads::Campaign do
  let(:campaign) { AdLeads::Campaign.new() }

  it 'inherits from AdLeads::Base' do
    expect(campaign.class.ancestors).to include AdLeads::Base
  end

end
