require 'faraday'
require 'json'
module  AdLeads
  class Client
    PROMOTABLE_TYPES = [:promotion]

    attr_accessor *Configuration::VALID_CONFIG_KEYS

    def initialize(options={})
      merged_options = AdLeads.options.merge(options)
      Configuration::VALID_CONFIG_KEYS.each do |key|
        send("#{key}=", merged_options[key])
      end
    end

    def get_promotion(id)
      get "/api/v1/promotions/#{id}"
    end

    def create(type, obj)
      if !PROMOTABLE_TYPES.include?(type)
        raise UnsupportedPromotionType.new("Unsupported promotion type: #{type}!")
      end
      post('/api/v1/promotions', class_for(type).promotion_params(obj))
    end

    def connection
      @connection ||= Faraday.new(:url => endpoint) do |faraday|
        faraday.headers['Content-Type'] = 'application/json'
        faraday.authorization :Token, authorization
        faraday.adapter  :httpclient  # make requests with Net::HTTP
      end
    end

    def get(path)
      request(:get, path)
    end

    def post(path, params = {})
      request(:post, path, params)
    end

    def request(method, path, params = {})
      res = connection.send(method, path) do |request|
        request.body = JSON.generate(params) if params
      end
      # rescue Faraday::Error::TimeoutError, Timeout::Error => error
      # rescue Faraday::Error::ClientError, JSON::ParserError => error
    end

    private
    def class_for(type)
      Kernel.const_get("AdLeads::#{type.to_s.split('_').collect(&:capitalize).join}")
    end
  end

  class UnsupportedPromotionType < StandardError; end
end
