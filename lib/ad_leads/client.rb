module AdLeads
  class Client
    include AdLeads::Client::CreativeGroup
    include AdLeads::Client::Ad
    include AdLeads::Client::Image
    include AdLeads::Client::Campaign

    attr_accessor *Configuration::VALID_CONFIG_KEYS
    attr_reader :last_response

    def initialize(options={})
      merged_options = AdLeads.options.merge(options)
      Configuration::VALID_CONFIG_KEYS.each do |key|
        send("#{key}=", merged_options[key])
      end
    end

    def get_reports(params)
      get("/reports/campaign/report", params)
    end

    def get(path, params = {})
      request(:get, path, params)
    end

    def post(path, params = {})
      request(:post, path, params)
    end

    def last_response_id
      JSON.parse(last_response.body)['data'].first
    end

    private

    def etag_opts(etag)
      {
        headers: { 'If-Match' => etag },
        multipart: true
      }
    end

    def connection(opts = {})
      opts[:headers] ||= { 'Accept' => 'application/json' }

      Faraday.new(url: endpoint) do |faraday|
        faraday.headers = opts[:headers]
        faraday.request :multipart if opts[:multipart]

        faraday.authorization :Bearer, token
        faraday.adapter  :httpclient
        faraday.request :url_encoded
        # faraday.response :logger
      end
    end

    def token
      @token ||= AdLeads::Token.new(client_id: client_id, principle: principle).token
    end

    def request(method, path, params = {})
      etag = params.delete(:etag)
      opts = etag ? etag_opts(etag) : {}

      response = connection(opts).send(method, path) do |request|
        request.params = params if method == :get
        request.body = params if method == :post
      end

        # Logger.new(STDOUT).info [
        #   '====================',
        #   endpoint: endpoint,
        #   method: method,
        #   path: path,
        #   body: response.body
        # ].join("\n")

      case response.status
      when 400 then raise ArgError.new response.body
      when 401 then raise AuthError.new "token: #{token}" + response.body.to_s
      when 412 then raise EtagMismatchError.new response.body
      when 500 then raise ApiServerError.new response.body
      else
        @last_response = response
      end
      # rescue Faraday::Error::TimeoutError, Timeout::Error => error
      # rescue Faraday::Error::ClientError, JSON::ParserError => error
    end
  end

  class ApiError < StandardError
    def initialize(message)
      Logger.new(STDOUT).error message
      super(message)
    end
  end
  class AuthError < ApiError; end
  class ApiServerError < ApiError; end
  class ArgError < ApiError; end
  class EtagMismatchError < ApiError; end
end
