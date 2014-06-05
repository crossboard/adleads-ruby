require 'spec_helper'

describe AdLeads::Client do
  let!(:client) { AdLeads::Client.new }
  let(:connection) { client.connection }
  let(:creative_group_id) { 12858 }
  let(:token) { '99d3492c-f82e-40c1-ac12-95a3c3326edc' }
  let(:file) { './spec/fixtures/test.jpg' }

  before do
    client.stub(:token).and_return(token)
    AdLeads::Client.stub(:new) { client }
  end

  context 'Network Requests' do
    describe 'Ad Campaign' do
      it 'uploads logo image, creates campaign using logo image, verifies and launches ad campaign' do

        params = {
          'name' => 'Creative Group Name',
          'productName' =>  'amazing product',
          'privacyPolicyUrl' => 'http://privacy_url'
        }

        creative_group = AdLeads::CreativeGroup.new
        creative_group.create!(params)

        params = {
          'type' => 'Mobile',
          'name' =>  'Ad name',
          'headerText' => 'get your ad on this phone today',
          'bodyText' => 'this is mobile ad body copy'
        }

        ad = AdLeads::Ad.new(creative_group.id)
        ad.create!(params)

        params = { 'type' => 'LogoImage' }

        image = AdLeads::Image.new( { creative_group_id: creative_group.id, ad_id: ad.id } )
        image.create!(params)
        image.upload!(file)

        params = {
          'name' => 'Campaign name',
          'verticals' =>  82,
          'offerIncentiveCategory' => 5,
          'collectedFields' => 'firstname,lastname,email,companyname',
          'budget' => 50,
          'creativeGroups' => creative_group.id
        }

        campaign = AdLeads::Campaign.new
        campaign.create!(params)
        campaign.verify!
        campaign.launch!

        expect(campaign.response.status).to eq(200)
        expect(JSON.parse(campaign.response.body)['result']).to eq true
      end
    end
  end

end
