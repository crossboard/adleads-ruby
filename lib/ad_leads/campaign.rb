module AdLeads
  class Client
    module Campaign
      def create_campaign(creative_id, options)
        post '/campaigns', options.merge(creativeGroups: creative_id)
      end

      def create_complete_campaign(options)
        create_creative_group(options[:creative_group])
        creative_id = self.last_response_id

        create_ad(creative_id, options[:ad])
        ad_id = self.last_response_id

        create_image(creative_id, ad_id, options[:image])
        image_id = self.last_response_id
        upload_image(creative_id, ad_id, image_id, options[:file])

        create_campaign(creative_id, options[:campaign])
      end

      def update_campaign(id, options)
        post campaign_path(id), options
      end

      def verify_campaign(id)
        get verify_campaign_path(id)
      end

      def launch_campaign(id)
        remaining_tries ||= 3
        post launch_campaign_path(id), etag: campaign_etag(id).headers['Etag']
      rescue AdLeads::EtagMismatchError
        remaining_tries -= 1
        retry unless remaining_tries.zero?
      end

      def signup_delivery(campaign_id, options={})
        post signup_delivery_path(campaign_id), options
      end

      private

      def campaign_path(id)
        "/campaigns/#{id}"
      end
      alias :campaign_etag_path :campaign_path

      def launch_campaign_path(id)
        campaign_path(id) + '/launch'
      end

      def verify_campaign_path(id)
        campaign_path(id) + '/plan'
      end

      def signup_delivery_path(id)
        campaign_path(id) + '/signupdelivery'
      end

      def campaign_etag(id)
        get campaign_etag_path(id)
      end
    end
  end
end
