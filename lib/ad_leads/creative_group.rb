module AdLeads
  class Client
    module CreativeGroup
      def create_creative_group(options)
        post '/creativegroups', options
      end
    end
  end
end
