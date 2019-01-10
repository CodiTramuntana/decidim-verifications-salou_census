# frozen_string_literal: true

module Decidim
  module Verifications
    module SalouCensus
      module Admin
        # A command to reverify a user with Salou Census
        class CheckSalouCensusUserAuthorization < Decidim::Verifications::PerformAuthorizationStep
          # Executes the command. Broadcasts these events:
          #
          # - :ok when everything is valid.
          # - :invalid in next cases:
          #     - SalouCensus cannot confirm user using data saved in DB
          #     - SalouCensus digested data is not same as saved in DB
          #
          # An invalid event, revokes Authorization and sends a notification
          # to the related user
          #
          # Returns nothing.
          def call
            if handler.salou_census_valid? && handler.verification_code_valid?
              broadcast(:ok)
            else
              revoke!
              send_revoke_email
              broadcast(:invalid)
            end
          end

          protected

          def revoke!
            authorization.destroy
          end

          def send_revoke_email
            Decidim::Verifications::SalouCensus::RevokedMailer.revoked(authorization.user).deliver_later
          end
        end
      end
    end
  end
end
