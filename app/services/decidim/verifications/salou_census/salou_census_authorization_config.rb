# frozen_string_literal: true

module Decidim
  module Verifications
    module SalouCensus
      # This is a handler for SalouCensus config values.
      # By now it only search for secret ones, but in future it could
      # be filled by a config record
      class SalouCensusAuthorizationConfig
        class << self
          # Access URL for SalouCensus WS
          def url
            Rails.application.secrets.salou_census[:salou_census_url]
          end

          # `key` value for SalouCensus WS
          def param(key)
            return unless valid_param?(key)
            Rails.application.secrets.salou_census[:"salou_census_#{key}"]
          end

          # SECRET value to perform SalouCensus' Digest
          def secret
            Rails.application.secrets.salou_census[:secret_key_salou_census]
          end

          private

          def valid_param?(key)
            %i[cli org ent usu pwd fecha nonce token].include? key.to_sym
          end
        end
      end
    end
  end
end
