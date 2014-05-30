# module AdLeadsApiWrapper
#   extend self

#   def create_campaign(ad_campaign)
Background do
  AdLeads::Campaign.new(ad_campaign).create!
end
# end
# def create_campaign(ad_campaign)
#   @campaign = AdLeads::Campaign.new(ad_campaign)

#   unless @campaign.create!

#   end

# ensure
#   persist(ad_campaign)
# end

# end

class AdLeads::Campaign > AdLeads::ApiResource

  attr_accesser :images, :creative_group, :content_holder, :campaign, :prerequisite

  def initialize(ad_campaign)
    @ad_campaign = ad_campaign
    @images = AdLeads::Images.new(ad_campaign.ad_content.images)
    @prerequisite [:images, :creative_group, :ad, :content_holder, :verify]
  end

  def create!
    complete_prerequisits
    create_campaign
  rescue
  end

  def complete_prerequisits
    @prerequisites.each do |prerequisite|
      AdLeads.const_get(prerequisite.to_s.split('_').collect(&:capitalize).join).perform!
    end
  end

private
  def persist(ad_campaign)
    @ad_campaign.update_attribute :publish_histroy, { Time.zone.now.to_i => summary }
  end

  def summary
    requests.each do |request|
      { method_called: {
          status: ,
          error: ,
          body: ,
          id:
      } }
    end
  end

end

class AdLeads::Image < AdLeads::ApiResource
  attr_accesor :queued, :complete

  def initialize(images)
    @queued = images
    @complete = []
  end

  def create!
    while !@images.complete?
      @images.process_next
    end
  end

  def process_next
    if create!(@queued.last)
      @complete << @queued.pop
      rescue
      end
    end

    def compelete?
      @queued.empty?
    end
  end

  class AdLeads::ApiResource

  end
