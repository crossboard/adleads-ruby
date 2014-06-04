module AdLeads
  module Configuration

    def configure
      yield self
    end

    VALID_CONNECTION_KEYS = [:endpoint, :token_endpoint, :user_agent].freeze
    VALID_OPTIONS_KEYS    = [:client_id, :private_key, :principle, :format].freeze
    VALID_CONFIG_KEYS     = VALID_CONNECTION_KEYS + VALID_OPTIONS_KEYS

    DEFAULT_ENDPOINT    = 'https://api.adleads.com'
    DEFAULT_TOKEN_ENDPOINT  = 'https://auth.adleads.com'
    DEFAULT_USER_AGENT  = "AdLeads API Ruby Gem #{AdLeads::VERSION}".freeze

    DEFAULT_FORMAT       = :json
    DEFAULT_CLIENT_ID    = 'client_id'
    DEFAULT_PRINCIPLE    = 'principle'
    DEFAULT_PRIVATE_KEY  = 'private_key'

    attr_accessor *VALID_CONFIG_KEYS

    # Make sure we have the default values set when we get 'extended'
    def self.extended(base)
      base.reset
    end

     def options
      Hash[ * VALID_CONFIG_KEYS.map { |key| [key, send(key)] }.flatten ]
    end

    def reset
      self.endpoint   = DEFAULT_ENDPOINT
      self.token_endpoint   = DEFAULT_TOKEN_ENDPOINT
      self.user_agent = DEFAULT_USER_AGENT
      self.client_id    = DEFAULT_CLIENT_ID
      self.private_key    = DEFAULT_PRIVATE_KEY
      self.principle    = DEFAULT_PRINCIPLE
      self.format     = DEFAULT_FORMAT
    end

  end
end
