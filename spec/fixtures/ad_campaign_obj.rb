{
  creative_group_info: {
    'name' => 'Creative Group Name',
    'productName' =>  promotion.name,
    'privacyPolicyUrl' => 'http://privacy_url' # ask dave
  },
  ad_info: {
    'type' => ad_content.kind,
    'name' =>  ad_content.name,
    'headerText' => ad_content.header,
    'bodyText' => ad_content.body
  },
  image_info: {
    'type' => image.kind
  },
  campaign_info: {
    'name' => ad_campaign.name,
    'verticals' =>  ad_campaign.verticals,
    'offerIncentiveCategory' => ad_campaign.offer_incentive_category,
    'collectedFields' => ad_campaign.collected_fields,
    'budget' => ad_campaign.spend,
    'creativeGroups' => creative_group.id
  }
}
