# frozen_string_literal: true

module Decidim
  module Verifications
    module SalouCensus
      # Custom helpers, scoped to SalouCensus verificator.
      #
      module Admin
        module SalouCensusHelper
          def reverify_all_action_button
            button_to t('actions.reverify_all', scope: 'decidim.verifications.salou_census.admin'),
                      %w[reverify_all verified_authorizations],
                      method: :patch,
                      class: 'button tiny button--title',
                      disabled: @verified_authorizations.empty?,
                      data: { confirm: t('actions.confirm_reverify_all', scope: 'decidim.verifications.salou_census.admin') }
          end
        end
      end
    end
  end
end
