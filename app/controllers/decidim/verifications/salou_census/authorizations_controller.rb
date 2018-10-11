# frozen_string_literal: true

module Decidim
  module Verifications
    module SalouCensus
      class AuthorizationsController < Decidim::ApplicationController
        helper_method :authorization

        before_action :load_authorization

        helper Decidim::Verifications::SalouCensus::ApplicationHelper

        def new
          enforce_permission_to :create, :authorization, authorization: @authorization

          @form = SalouCensusForm.new
        end

        def create
          enforce_permission_to :create, :authorization, authorization: @authorization

          @form = SalouCensusForm.from_params(params.merge(user: current_user))

          ConfirmSalouCensusUserAuthorization.call(authorization, @form) do
            on(:ok) do
              flash[:notice] = t("authorizations.create.success", scope: "decidim.verifications.salou_census")
              redirect_to decidim_verifications.authorizations_path
            end
            on(:invalid) do
              flash.now[:alert] = t("authorizations.create.error", scope: "decidim.verifications.salou_census")
              render :new
            end
          end
        end

        def edit
          enforce_permission_to :update, :authorization, authorization: @authorization

          @form = SalouCensusForm.new
        end

        def update
          enforce_permission_to :update, :authorization, authorization: @authorization

          @form = SalouCensusForm.from_params(params.merge(user: current_user, persisted: authorization))

          ConfirmSalouCensusUserAuthorization.call(authorization, @form) do
            on(:ok) do
              flash[:notice] = t("authorizations.create.success", scope: "decidim.verifications.salou_census")
              redirect_to decidim_verifications.authorizations_path
            end
            on(:invalid) do
              flash.now[:alert] = t("authorizations.create.error", scope: "decidim.verifications.salou_census")
              render :edit
            end
          end
        end

        private

        def authorization
          @authorization_presenter ||= AuthorizationPresenter.new(@authorization)
        end

        def load_authorization
          @authorization = Decidim::Authorization.find_or_initialize_by(
            user: current_user,
            name: "salou_census"
          )
        end
      end
    end
  end
end
