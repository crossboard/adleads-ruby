require 'spec_helper'

describe AdLeads::Image do
  let(:image) { AdLeads::Image.new({}) }

  it 'inherits from AdLeads::Base' do
    expect(image.class.ancestors).to include AdLeads::Base
  end

end
