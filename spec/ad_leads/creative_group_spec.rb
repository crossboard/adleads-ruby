require 'spec_helper'

describe AdLeads::CreativeGroup do
  let(:creative_group) { AdLeads::CreativeGroup.new({}) }

  it 'inherits from AdLeads::Base' do
    expect(creative_group.class.ancestors).to include AdLeads::Base
  end

end
