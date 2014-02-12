require "s2s/auth/version"
require "time"
require "active_support/key_generator"
require "active_support/message_verifier"
require "active_support/message_encryptor"
require "active_support/key_generator"
require_relative "serializer"

module S2S
  module Auth
    module_function

    @secret = nil
    @salt = nil
    @sign_salt = nil
    @app_name = nil
    @encryptor = nil

    # Setups the S2S::Auth module.
    #
    # @arg [Hash] opts
    # @raise [ArgumentError] if the passed option doesn't contain a
    # secret.
    # @return [Bool] true
    def setup(opts={})
      clear
      @secret = opts[:secret] || opts["secret"]
      @app_name = opts[:app] || opts["app"] 
      @salt = opts[:salt] || opts["salt"]
      @sign_salt = opts[:sign_salt] || opts["sign_salt"]
      if [@secret, @app_name, @salt, @sign_salt].any?{|v| v.nil? || v.empty?}
        raise ArgumentError.new("This module needs to be setup following keys: secret, app, salt, sign_salt")
      end
      @serializer = opts[:serializer] || opts["serializer"] || S2S::Auth::JsonSerializer
      @iterations = opts[:iterations] || opts["iterations"] || 1000
      keygen = ActiveSupport::CachingKeyGenerator.new(ActiveSupport::KeyGenerator.new(@secret, iterations: @iterations))
      secret = keygen.generate_key(@salt)
      sign_secret = keygen.generate_key(@sign_salt)
      @encryptor = ActiveSupport::MessageEncryptor.new(secret, sign_secret, { serializer: @serializer } )
      return true
    end

    # Clears the settings that were set during setup.
    def clear
      @secret = nil
      @salt = nil
      @sign_salt = nil
      @app_name = nil
      @iterations = nil
      @encryptor = nil
      @serializer = nil
    end

    # Returns the module's settings.
    def settings
      {
        secret: @secret,
        salt: @salt,
        sign_salt: @sign_salt,
        app_name: @app_name,
        serializer: @serializer,
        iterations: @iterations,
        encryptor: @encryptor
      }
    end

    # Returns a hash representing the auth header needed to be
    # sent with the S2S request.
    # Make sure to call #setup first.
    #
    # @return
    def header
      {Authorization: "Bearer #{generate_token}"}
    end

    # Generate an encypted and signed token.
    # Tokens are time sensitive and usually expire in a few seconds.
    def generate_token
      if @app_name.nil? || @encryptor.nil?
        raise ArgumentError.new("Can't generate a S2S header before setting up the class")
      end
      @encryptor.encrypt_and_sign({app: @app_name, ts: Time.now.utc.iso8601})
    end

    # Checks that a token is valid and return a hash with its content.
    # Note that no logic is done to verify that the token is recent.
    # @raise [ActiveSupport::MessageVerifier::InvalidSignature]
    def parse_token(token)
      @encryptor.decrypt_and_verify(token)
    end

  end
end
