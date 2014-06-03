require 'spec_helper'

describe AdLeads::Client do
  let(:client) { AdLeads::Client.new }
  let(:connection) { client.connection }
  let(:creative_group_id) { 12858 }
  let(:token) { '3141ac1f-5f8f-4376-8006-e2241b8b9f1a' }

  before do
    client.stub(:token).and_return(token)
  end

  context 'Network Requests' do
    describe 'Ad Campaign' do
      it 'uploads logo image, creates campaign using logo image, verifies and launches ad campaign' do

        # params = {
        #   'name' => 'test creative group',
        #   'productName' =>  'test product',
        #   'privacyPolicyUrl' => 'http://privacy_url'
        # }

        # creative_group = AdLeads::CreativeGroup.new
        # creative_group.create!(params)

        # params = {
        #   'type' => 'Mobile',
        #   'name' =>  'test mobile ad',
        #   'headerText' => 'get your ad on this phone today',
        #   'bodyText' => 'this is mobile ad body copy'
        # }

        # ad = AdLeads::Ad.new(creative_group.id)
        # ad.create!(params)

        # params = { 'type' => 'LogoImage' }

        # image = AdLeads::Image.new( { creative_group_id: creative_group.id, ad_id: ad.id } )
        # image.create!(params)
        # image.upload!(file)

        params = {
          'name' => 'test',
          'verticals' =>  82,
          'offerIncentiveCategory' => 5,
          'collectedFields' => 'firstname,lastname,email,companyname',
          'budget' => 50,
          'creativeGroups' => creative_group.id
        }

        campaign = AdLeads::Campaign.new
        campaign.create!(params)

        params = {
          'pricingModel' => 'CPL',
          'emailOnly' => true
        }

        campaign.update(params)
        campaign.verify!
        campaign.launch!

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['result']).to eq true
      end
    end
  end

end
