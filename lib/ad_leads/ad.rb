module AdLeads
  class Client
    module Ad
      def create_ad(creative_group_id, options)
        post "/creativegroups/#{creative_group_id}/creatives", options
      end
    end
  end
end
