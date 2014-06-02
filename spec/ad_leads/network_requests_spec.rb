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

    describe 'Creating content for Ad Campaign' do

      #set from output from 'creates mobile ad'
      let(:creatives_id) { 32276 }

      context 'For mobile platform' do

        it 'creates creative group' do
          params = {
            'name' => 'test creative group',
            'productName' =>  'test product',
            'privacyPolicyUrl' => 'http://privacy_url'
          }
          response = client.create_creative_group(params)
          expect(response.status).to eq(200)
        end

        it 'creates mobile ad' do
          params = {
            'type' => 'Mobile',
            'name' =>  'test mobile ad',
            'headerText' => 'get your ad on this phone today',
            'bodyText' => 'this is mobile ad body copy'
          }
          response = client.create_ad(creative_group_id, params)
          expect(response.status).to eq(200)
        end

        it 'creates logo image, gets etag, and uploads image with etag verification' do
          params = { 'type' => 'LogoImage' }
          ids = { group: creative_group_id, creative: creatives_id }

          response = client.create_content_holder(ids, params)
          expect(response.status).to eq(200)
          ids[:image] = JSON.parse(response.body)['data'].first
          response = client.get_content_etag(ids)
          etag = response.headers['ETag']
          file_name = 'test.jpg'
          response = client.upload_image(ids, etag, file_name)
          expect(response.status).to eq(200)
        end
      end

      context 'for email platform' do
        #TODO implement this, similar to mobile
      end
    end

    describe 'Ad Campaign' do
      it 'creates a campaign' do
        params = {
          'name' => 'test',
          'verticals' =>  82,
          'offerIncentiveCategory' => 5,
          'collectedFields' => 'firstname,lastname,email,companyname',
          'budget' => 50,
        }
        response = client.create_campaign(params)
        expect(response.status).to eq(200)
      end

      it 'creates campaign and gets status' do
        params = {
          'name' => 'test',
          'verticals' =>  82,
          'offerIncentiveCategory' => 5,
          'collectedFields' => 'firstname,lastname,email,companyname',
          'budget' => 50,
          'creativeGroups' => creative_group_id
        }
        response = client.create_campaign(params)
        ad_campaign_id = JSON.parse(response.body)['data'].first

        status = client.get_campaign_status(ad_campaign_id)
        expect(status).to eq 'New'
      end

      it 'uploads logo image, creates campaign using logo image, verifies and launches ad campaign' do

        params = {
          'name' => 'test creative group',
          'productName' =>  'test product',
          'privacyPolicyUrl' => 'http://privacy_url'
        }

        # =begin
        #   creative_group = AdLeads::CreativeGroup.new(params)
        #   creative_group.create!

        #   class CreativeGroup
        #     attr_accessor :response, :params

        #     def initialize(params)
        #       @params = params
        #     end

        #     def create
        #       self.response = client.create_creative_group(params)
        #     end

        #     def id
        #       JSON.parse(response.body)['data'].first
        #     end

        #     def status
        #       response.status
        #     end
        #   end
        # =end

        response = client.create_creative_group(params)
        creative_group_id = JSON.parse(response.body)['data'].first
        expect(response.status).to eq(200)

        params = {
          'type' => 'Mobile',
          'name' =>  'test mobile ad',
          'headerText' => 'get your ad on this phone today',
          'bodyText' => 'this is mobile ad body copy'
        }

        # =begin
        #   ad = AdLeads::Ad.new(params, creative_group.id)
        #   ad.create!

        #   class Ad
        #     attr_accessor :response, :params, :creative_group_id

        #     def initialize(params, creative_group_id)
        #       @params = params
        #       @creative_group_id = creative_group_id
        #     end

        #     def create
        #       self.response = client.create_ad(params, creative_group_id)
        #     end

        #     def id
        #       JSON.parse(response.body)['data'].first
        #     end

        #     def status
        #       response.status
        #     end
        #   end
        # =end

        response = client.create_ad(creative_group_id, params)
        creatives_id = JSON.parse(response.body)['data'].first
        expect(response.status).to eq(200)

        params = { 'type' => 'LogoImage' }

        # =begin
        #   image = AdLeads::Image.new(
        #     { params: params, creative_group_id: creative_group.id, ad_id: ad.id }
        #   )
        #   image.create!

        #   class AdLeads::Image
        #     attr_accessor :response, :params, :creative_group_id, :ad_id

        #     def initialize(opts)
        #       @params = opts[:params]
        #       @creative_group_id = opts[:creative_group_id]
        #       @ad_id = opts[:ad_id]
        #     end

        #     def create
        #       self.response = client.create_content_holder(ids, params)
        #     end

        #     def ids
        #       { group: creative_group_id, creative: ad_id }
        #     end

        #     def id
        #       JSON.parse(response.body)['data'].first
        #     end

        #     def status
        #       response.status
        #     end

        #     def upload_file(file)
        #       client.upload_image(ids, etag, file)
        #     end

        #     def etag_path
        #       [
        #         'creativegroups',
        #         creative_group_id,
        #         'creatives',
        #         ad_id,
        #         'images',
        #         id
        #       ].join('/')
        #     end

        #     def etag
        #       request(:get, etag_path)
        #     end
        #   end
        # =end

        ids = { group: creative_group_id, creative: creatives_id }
        response = client.create_content_holder(ids, params)
        expect(response.status).to eq(200)
        image_id = JSON.parse(response.body)['data'].first
        ids[:image] = image_id

        response = client.get_content_etag(ids)
        expect(response.status).to eq(200)
        etag = response.headers['ETag']
        response = client.upload_image(ids, etag, 'test.jpg')
        expect(response.status).to eq(200)

        # =begin
        #   image.upload_file(file)
        # =end

        params = {
          'name' => 'test',
          'verticals' =>  82,
          'offerIncentiveCategory' => 5,
          'collectedFields' => 'firstname,lastname,email,companyname',
          'budget' => 50,
          'creativeGroups' => creative_group_id
        }
        response = client.create_campaign(params)
        ad_campaign_id = JSON.parse(response.body)['data'].first

        params = {
          'pricingModel' => 'CPL',
          'emailOnly' => true
        }
        client.update_campaign(ad_campaign_id, params)
        expect(response.status).to eq(200)

        client.verify_campaign(ad_campaign_id)
        expect(response.status).to eq(200)

        etag = client.get_campaign_etag(ad_campaign_id)

        response = client.launch_campaign(ad_campaign_id, etag)
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['result']).to eq true
      end

      it 'creates, verifies, and sets signup delivery on campaign' do
        params = {
          'name' => 'test',
          'verticals' =>  82,
          'offerIncentiveCategory' => 5,
          'collectedFields' => 'firstname,lastname,email,companyname',
          'budget' => 50,
          'creativeGroups' => creative_group_id
        }
        response = client.create_campaign(params)
        ad_campaign_id = JSON.parse(response.body)['data'].first

        client.verify_campaign(ad_campaign_id)
        response = client.get("/campaigns/#{ad_campaign_id}")
        etag = response.headers['ETag']

        params = {
          'dataSink' => 'RealtimeHTTP',
          'method' => 'POST',
          'url' => 'my_url'
        }
        response = client.configure_campaign_signups(ad_campaign_id, etag, params)
        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['result']).to eq true
      end
    end

    describe 'Reporting' do
      let(:campaign_id) {
        params = {
          'name' => 'test',
          'verticals' =>  82,
          'offerIncentiveCategory' => 5,
          'collectedFields' => 'firstname,lastname,email,companyname',
          'budget' => 50,
        }
        response = client.create_campaign(params)
        JSON.parse(response.body)['data'].first
      }

      it 'returns a list of expected stats' do
        params = {
          'campaignIds' => "#{campaign_id}",
          'startDate' => '201405120800',
          'endDate' => '201405120800'
        }
        response = client.get_reports(params)
        parsed_response = JSON.parse(response.body)['campaigns']['campaign'].first
        expected_keys = [
          'received', 'accepted', 'duplicates', 'invalids', 'averageCpl', 'impressions'
        ]
        expected_keys.each do |k|
          expect(parsed_response.keys).to include k
        end
      end
    end
  end

end
