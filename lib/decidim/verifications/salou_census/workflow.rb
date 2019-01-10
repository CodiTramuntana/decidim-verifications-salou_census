# frozen_string_literal: true

Decidim::Verifications.register_workflow(:salou_census_authorization_handler) do |workflow|
  workflow.form = "Decidim::Verifications::SalouCensus::SalouCensusAuthorizationHandler"
  workflow.engine = Decidim::Verifications::SalouCensus::Engine
end
