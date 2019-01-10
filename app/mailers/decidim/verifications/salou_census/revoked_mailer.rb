# frozen_string_literal: true

module Decidim
  module Verifications
    module SalouCensus
      # A custom mailer for sending notifications to users when
      # they join a meeting.
      class RevokedMailer < Decidim::ApplicationMailer
        def revoked(user)
          with_user(user) do
            @user = user
            @organization = @user.organization
            subject = I18n.t('revoked.subject', scope: 'decidim.verifications.salou_census.revoked_mailer')

            mail(to: user.email, subject: subject)
          end
        end
      end
    end
  end
end
