# frozen_string_literal: true

module Decidim
  module Verifications
    module SalouCensus
      # A command to confirm a user with Salou Census
      class ConfirmSalouCensusUserAuthorization < Decidim::Verifications::ConfirmUserAuthorization
        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid in next cases:
        #     - authorization is already granted
        #     - document number or birthdate are not valid (bad format or blank)
        #     - Digest of form data already exists (new) or are not equal as saved in DB
        #     - Salou Census cannot confirm user
        #
        # Returns nothing.

        def call
          return broadcast(:already_confirmed) if authorization.granted?

          return broadcast(:invalid) unless form.valid?

          return broadcast(:invalid) unless form.check_verification_code

          return broadcast(:invalid) unless form.salou_census_valid?

          if confirmation_successful?
            assign_verification_data
            authorization.grant!
            broadcast(:ok)
          else
            broadcast(:invalid)
          end
        end

        protected

        def assign_verification_data
          authorization.attributes = {
            metadata: form.metadata
          }
        end
      end
    end
  end
end
