module RailsExtensions
  module CachingKeyGenerator
    module GenerateKey
      def generate_key(salt, key_size=32)
       # Original:
       #   def generate_key(salt, key_size=64)
       # Without this monkey patch, I was getting 'ArgumentError (key must be 32 bytes)' at"
       # activesupport (5.0.0.rc1) lib/active_support/message_encryptor.rb:72: in `key='"
        Rails.logger.warn "CdLB: Monkey Patch KeyGenerator#generate_key: defaults key_size to 32 bytes not 64."
        super(salt, key_size)
      end
    end
  end
end

module ActiveSupport
  class CachingKeyGenerator
    prepend RailsExtensions::CachingKeyGenerator::GenerateKey
  end
end
