require 'spec_helper'
require './spec/fixtures/deal.rb'
require 'pry'

describe AdLeads::Client do
  let(:client) { AdLeads::Client.new }
  let(:connection) { client.connection }
  let(:config_keys) { AdLeads::Configuration::VALID_CONFIG_KEYS }
  #When creating a new token, set this value to output from 'creates creative group' spec
  let(:creative_group_id) { 12858 }
  let(:token) { 'a2b43ab1-8d09-4ec4-8568-7bb1872cc63b' }

  before do
    client.stub(:token).and_return(token)
  end

  it 'inherits config' do
    Faraday.stub(:new) { connection }
    expect(client).to respond_to(config_keys.sample)
  end

  context 'connection' do
    let(:connection) { double(:http_connection) }

    it 'calls token' do
      expect(client).to receive(:token).and_return('xyz')
      client.send(:connection)
    end
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
          puts "creative group id : #{response.body}"
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
          puts "creatives_id : #{response.body}"
          expect(response.status).to eq(200)
        end

        it 'creates logo image, gets etag, and uploads image with etag verification' do
          params = { 'type' => 'LogoImage' }
          ids = { group: creative_group_id, creative: creatives_id }

          response = client.create_content_holder(ids, params)
          expect(response.status).to eq(200)
          ids[:image] = JSON.parse(response.body)['data'].first
          puts "get etag using etag_id : #{ids[:image]}"
          response = client.get_content_etag(ids)
          etag = response.headers['ETag']
          puts "upload image using etag : #{etag}"
          file_name = 'test.jpg'
          response = client.upload_image(ids, etag, file_name)
          expect(respond_tose.status).to eq(200)
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
        puts "create campaign with id : #{ad_campaign_id}"

        status = client.get_campaign_status(ad_campaign_id)
        expect(status).to eq 'New'
      end

      it 'uploads logo image, creates campaign using logo image, verifies and launches ad campaign' do

        params = {
          'name' => 'test creative group',
          'productName' =>  'test product',
          'privacyPolicyUrl' => 'http://privacy_url'
        }
        response = client.create_creative_group(params)
        creative_group_id = JSON.parse(response.body)['data'].first
        puts "creative_group_id : #{creative_group_id}"
        expect(response.status).to eq(200)

        params = {
          'type' => 'Mobile',
          'name' =>  'test mobile ad',
          'headerText' => 'get your ad on this phone today',
          'bodyText' => 'this is mobile ad body copy'
        }
        response = client.create_ad(creative_group_id, params)
        puts "response body : #{response.body}"
        creatives_id = JSON.parse(response.body)['data'].first
        puts "creatives_id : #{creatives_id}"
        expect(response.status).to eq(200)

        params = { 'type' => 'LogoImage' }
        ids = { group: creative_group_id, creative: creatives_id }
        response = client.create_content_holder(ids, params)
        expect(response.status).to eq(200)
        image_id = JSON.parse(response.body)['data'].first
        ids[:image] = image_id

        puts "create etag using image_id : #{image_id}"
        response = client.get_content_etag(ids)
        expect(response.status).to eq(200)
        etag = response.headers['ETag']
        puts "upload image using etag : #{etag}"
        response = client.upload_image(ids, etag, 'test.jpg')
        expect(response.status).to eq(200)

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
        puts "create campaign with id : #{ad_campaign_id}"

        params = {
          'pricingModel' => 'CPL',
          'emailOnly' => true
        }
        client.update_campaign(ad_campaign_id, params)
        expect(response.status).to eq(200)

        client.verify_campaign(ad_campaign_id)
        expect(response.status).to eq(200)

        etag = client.get_campaign_etag(ad_campaign_id)
        puts "etag : #{etag}"

        response = client.launch_campaign(ad_campaign_id, etag)
        puts "response body : #{response.body}"
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
        puts "create campaign with id : #{ad_campaign_id}"

        client.verify_campaign(ad_campaign_id)
        response = client.get("/campaigns/#{ad_campaign_id}")
        etag = response.headers['ETag']
        puts "etag : #{etag}"

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
