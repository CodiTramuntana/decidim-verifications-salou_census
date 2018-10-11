# frozen_string_literal: true

require 'decidim/verifications/salou_census/admin'
require 'decidim/verifications/salou_census/engine'
require 'decidim/verifications/salou_census/admin_engine'
require 'decidim/verifications/salou_census/workflow'

module Decidim
  # This namespace holds the logic of the `Verifications::SalouCensus` component. This component
  # allows users to create Verifications::SalouCensus in a participatory space.
  module Verifications
    module SalouCensus
      autoload :SalouCensusFormatter, 'decidim/verifications/salou_census/salou_census_formatter'
      autoload :SalouCensusDigest, 'decidim/verifications/salou_census/salou_census_digest'
    end
  end
end
