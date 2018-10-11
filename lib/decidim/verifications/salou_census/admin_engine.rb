# frozen_string_literal: true

module Decidim
  module Verifications
    module SalouCensus
      # This is the engine that runs on the public interface of `VerificationsSalouCensus`.
      class AdminEngine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::SalouCensus::Admin

        paths['db/migrate'] = nil
        paths['lib/tasks'] = nil

        routes do
          resources :verified_authorizations, only: :index do
            patch :reverify_all, on: :collection
          end

          root to: 'verified_authorizations#index'
        end
      end
    end
  end
end
