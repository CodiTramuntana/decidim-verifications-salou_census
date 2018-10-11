# frozen_string_literal: true

module Decidim
  module Verifications
    module SalouCensus
      #
      # Decorator for SalouCensus authorizations.
      #
      class AuthorizationPresenter < SimpleDelegator
        #
        # Identifier of user in SalouCensus system
        #
        def perscod
          metadata["perscod"]
        end

        #
        # Digested data of SalouCensus
        #
        def verification_code
          metadata["verification_code"]
        end
      end
    end
  end
end
