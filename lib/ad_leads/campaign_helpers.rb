class CampaignHelpers

  def creative_group_params
    {
      'name' => @ad_campaign_obj[:campaign_info][:name],
      'productName' => @ad_campaign_obj[:content_info][:name],
      'active' => @ad_campaign_obj[:content_info][:active],
      'privacyPolicyUrl' => @ad_campaign_obj[:content_info][:privacy]
    }
  end

  def ad_params
    {
      'name' => @ad_campaign_obj[:content_info][:name]
      'type' => @ad_campaign_obj[:content_info][:type],
      ##mobile
      'headerText' => @ad_campaign_obj[:content_info][:headerText],
      'bodyText' => @ad_campaign_obj[:content_info][:bodyText],
      ##email
      'fromAddress' => @ad_campaign_obj[:campaign_info][:email],
      'subject' => @ad_campaign_obj[:content_info][:subject],
      'companyName' => @ad_campaign_obj[:campaign_info][:dba],
      'mailingAddress' => @ad_campaign_obj[:campaign_info][:address],
      'calltoAction' => @ad_campaign_obj[:campaign_info][:cta],
      'preHeader' => @ad_campaign_obj[:campaign_info][:pre_header]
    }
  end

  def content_holder_params
    {
      'type' => @ad_campaign_obj[:content_info][:image_type]
    }
  end

  def campaign_params
    {
      'name' => @ad_campaign_obj[:content_info][:name],
      'verticals' =>  @ad_campaign_obj[:content_info][:verticals],
      'offerIncentiveCategory' => @ad_campaign_obj[:content_info][:incentives],
      'collectedFields' => @ad_campaign_obj[:content_info][:collected_fields],
      'budget' => @ad_campaign_obj[:campaign_info][:spend],
      'creativeGroups' => @creative_group_id
    }
  end
