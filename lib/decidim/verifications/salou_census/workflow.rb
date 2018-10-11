# frozen_string_literal: true

Decidim::Verifications.register_workflow(:salou_census) do |workflow|
  workflow.engine = Decidim::Verifications::SalouCensus::Engine
  workflow.admin_engine = Decidim::Verifications::SalouCensus::AdminEngine
end
