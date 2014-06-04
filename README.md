# AdLeads

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'ad_leads'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ad_leads

## Usage
Steps are outline by request here - https://api.adleads.com/doc/index.html#tutorial

In order to launch a campaign, there are two objects that need to be created - an ad campaign and a creative group.
The creative group holds all of the content (images) associated with an ad campaign, and an ad campaign has a creative_group_id parameter that is required in order to launch the ad campaign.
It is recommended by AdLeads to create the creative group and upload content first, and then associate that creative group with the campaign upon creation of the campaign, however if the creative isn't available at the time of the ad campaign creation, it can be created later and associated by posting an update to an (unlaunched) ad campaign.
Below are the processes for creating a complete creative group as well as a complete, launchable ad campaign.

###Creative Group(all content):

1 - '#create_creative_group(params)'

Required in params hash:

|Param            | Type |
|---------------- | -----|
|name             |string|
|productName      |string|
|privacyPolicyUrl |string|

POSTs to https://api.adleads.com/creativegroups

A successful post returns a creative_group_id

2 - '#create_ad(creative_group_id, type)'

Required Arguments:

|Arg| type | Description| Additional info |
|----|-----|-------|---|
|creative_group_id| integer | id returned by #create_creative_group| |
|type | string | Choose between 'Email', 'Mobile' or 'Standard'| First letter must be capitalized |

POSTs to https://api.adleads.com/creativegroups/#{creative_group_id}/creatives

A successful post returns a creatives_id

3 - '#create_content_holder(ids, type)'

Required Arguments:

|Arg| type | Description | Additional info |
|---|-----|-----|-----|
|ids| hash| keys: creative_group & creatives, values: ids returned by #create_creative_group & #create_ad | |
|type| string| LogoImage, OfferImage, or MainImage | Must be camel-cased |

  POSTs to https://api.adleads.com/creativegroups/#{creative_group_id}/creatives/#{creatives_id}/images
  a successful post returns an image_id

4 - '#get_content_etag(ids)'

Required Arguments:

|Arg| type | Description | Additional info |
|---|-----|-----|-----|
|ids|hash| keys: creative_group, creatives, image, values: ids returned by #create_creative_group, #create_ad & #create_content_holder ||

  GETs from https://api.adleads.com/creativegroups/#{creative_group_id}/creatives/#{creatives_id}/images/#{image_id}
  a successful get returns an ETAG in the header

5 - '#upload_image(ids, etag, file)'

Required Arguments:

|Arg| type | Description | Additional info |
|---|-----|-----|-----|
|ids|hash| keys: creative_group, creatives, image, values: ids returned by #create_creative_group, #create_ad & #create_content_holder ||
|etag|integer|returned by #get_content_etag ||

  POSTs to https://api.adleads.com/creativegroups/#{creative_group_id}/creatives/#{creatives_id}/images/#{image_id} with an If_Match against the Etag in the request header
  a successful get returns a result of true

####Steps 3 through 5 should be repeated for each image that needs to be uploaded to a campaign

###AdCampaign:

1 - '#create_campaign(params)'

Params required in params hash:

|key|type|options|
|---|---|-----|
|name|string| |
|verticals| comma-separated list of numbers in a string| see below for table of IDs and options |
|offerIncentiveCategory| comma-separated list of numbers in a string | see below for table of IDs and options |
|budget| interval| |

  POSTs to https://api.adleads.com/campaigns
  a successful post returns the campaign id

2 - '#update_campaign(ad_campaign_id, params)'

Required Arguments:

|Arg|type|info|
|---|----|-----
|campaign_id|integer|returned from #create_campaign|
|params|hash| update any values on campaign|

  POSTs to https://api.adleads.com/campaigns/#{campaign_id}
  Returns true on success

3 - '#verify_campaign(ad_campaign_id)'
Required Arguments:

|Arg|type|info|
|---|----|-----
|campaign_id|integer|returned from #create_campaign|

  GETs from https://api.adleads.com/campaigns/#{ad_campaign_id}
  a successful request returns totalVolume, costPerSignup, duration, maxCostPerSignup params that need to be specified before a campaign can launch

4 - '#get_campaign_etag(ad_campaign_id)'

Required Arguments:

|Arg|type|info|
|---|----|-----
|campaign_id|integer|returned from #create_campaign|

  GETs from https://api.adleads.com/campaigns/#{ad_campaign_id}
  a successful request returns the ETag in the request header

5 - '#launch_campaign(ad_campaign_id, etag, params{optional})'

Required Arguments:

|Arg|type|info|
|---|----|-----
|campaign_id|integer|returned from #create_campaign|
|etag|etag|returned from #get_campaign_etag|

  POSTs to https://api.adleads.com/campaigns/#{ad_campaign_id}/launch
  a successful post returns true

In order to launch a campaign successfully, the following attrs must be defined on the campaign:

|Param|Type|Extra info|
|-----|----|----------|
|name|string||
|verticals|comma-separated string of list IDs|options listed in table below|
|offerIncentiveCategory|comma-separated string of list IDs|options listed in table below|
|collectedFields|comma-separated string of field types|options listed in table below|
|budget|integer||
|creativeGroups|integer| this is the ID from the creative group|

###Additional campaign-level methods:

'#get_campaign_status(ad_campaign_id)'
  GETs from https://api.adleads.com/campaigns/#{ad_campaign_id}/
  returns the campaign status in the body

'#get_reports(params)'
  Required Params:

|key|value|format|
|----|----|------|
|campaignIds| integers| comma separated string of campaign ids|
|startDate| date| YYYYMMDDHHMM|
|endDate| date| YYYYMMDDHHMM|

  GETs from https://api.adleads.com/reports/campaign/report
  returns an array of hashes, each hash with campaign reporting data

'#configure_campaign_signups(ad_campaign_id, etag, params)'
  This can be done before or after launching a campaign, but should be done before launch so all signups are directed to the correct endpoint
  args required: campaign_id, etag(for campaign)
  params: { 'dataSink' => 'RealtimeHTTP', 'method' => 'Post', 'url' => '#{url}' }
  POSTs to https://api.adleads.com/campaigns/#{ad_campaign_id}/signupdelivery
  a successful post returns true

### AdLeads key references

offerIncentiveCategories:

|Name|ID|Sescription|Display Name|
|----|---|-----------|---------|
|ImmediateDisc| 5|Main goal is to generate sales with a coupon or discount of 25% of more| Immediate Discount|
|FreeProduct|4|Main goal is to increase consumer engagement by offering a free product or free trial| Free Product|
|DealNewsletter|2|Main goal is to generate subscriptions for your deals, discounts and updates newsletter| Newsletter|
|FreeInfo|3|Main goal is to educate the consumer by providing important information| Free Information |
|JoinAdvocacy|6|Main goals are to increase membership, awareness and don ations| Join Advocacy|
|Awareness|1|Main goal is to generate awareness and excitement | Awareness|

verticals:

|Name|ID|related verticals|
|----|---|------------------|
|apparel |82| |
|automotive|307|310|
|beauty_n_fitness|64| |
|consumer_electronics|1| |
|daily_deals|46| |
|education|288| |
|entertainment|78| |
|finance|123| |
|food_n_drink|95| |
|health|59| |
|home_n_garden|108| |
|internet_n_telecom|27| |
|non_profit|18| |
|other|311| |
|parenting|156| |
|pets_n_animals|8| |
|professional_services|310| |
|real_estate|309| |
|shopping|127| |
|sports|256| |
|travel|30| |

collectedFields:

|type|
|----|
|firstname|
|middlename|
|lastname|
|companyname|
|phone|
|address1|
|address2|
|city|
|state|
|country|
|postalcode|
|email|
|ip|
|timestamp|
|gender|
|dateofbirth|
|childdob|
|agerange|

===============================================

    AdLeads::Client.configure do |config|
      config.client_id = 'xyz',
      config.principle = 'me@example.com',
      config.private_key = 'private_key'
    end
    client = AdLeads::Client.new

## Contributing

1. Fork it ( http://github.com/<my-github-username>/ad_leads/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# Network test

   describe 'network request' do
     before { Faraday.unstub(:new) }

     let(:client) { AdLeads::Client.new(
       client_id: 'xyz',
       principle: 'me@example.com'
       )
     }
     it 'GETs campaigns' do
       res = client.get('/campaigns?launched=false')
       puts res.body
     end
   end
