require 'spec_helper'

describe AdLeads::Ad do
  let(:ad) { AdLeads::Ad.new({ 'foo' => 'bar'}, 1) }

  it 'inherits from AdLeads::Base' do
    expect(ad.class.ancestors).to include AdLeads::Base
  end

end
