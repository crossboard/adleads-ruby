module AdLeads
  module Configuration

    def configure
      yield self
    end

    VALID_CONNECTION_KEYS = [:endpoint, :user_agent].freeze
    VALID_OPTIONS_KEYS    = [:api_key, :authorization, :format].freeze
    VALID_CONFIG_KEYS     = VALID_CONNECTION_KEYS + VALID_OPTIONS_KEYS

    DEFAULT_ENDPOINT    = ''
    DEFAULT_USER_AGENT  = "AdLeads API Ruby Gem #{AdLeads::VERSION}".freeze

    DEFAULT_API_KEY      = nil
    DEFAULT_AUTHORIZATION = 'Token access_token'
    DEFAULT_FORMAT       = :json

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
      self.user_agent = DEFAULT_USER_AGENT
      self.api_key    = DEFAULT_API_KEY
      self.authorization    = DEFAULT_AUTHORIZATION
      self.format     = DEFAULT_FORMAT
    end

  end
end
