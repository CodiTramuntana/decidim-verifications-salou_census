# frozen_string_literal: true

module Decidim
  module Verifications
    module SalouCensus
      module Admin
        class VerifiedAuthorizationsController < Decidim::Admin::ApplicationController
          layout "decidim/admin/users"

          helper Decidim::Verifications::SalouCensus::Admin::SalouCensusHelper

          def index
            authorize! :index, Authorization
          end

          def reverify_all
            authorize! :update, Authorization

            verified_authorizations.each do |verified_authorization|
              handler = SalouCensusAuthorizationHandler.from_model(verified_authorization)
              CheckSalouCensusUserAuthorization.call(verified_authorization, handler)
            end

            flash[:info] = t("verified_authorizations.reverify_all.process_completed", scope: "decidim.verifications.salou_census.admin")

            redirect_to root_path
          end

          private

          def verified_authorizations
            @verified_authorizations ||= Authorizations.new(organization: current_organization, user: nil, name: "salou_census", granted: true)
                                                       .query
          end
        end
      end
    end
  end
end
