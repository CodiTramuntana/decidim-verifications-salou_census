# frozen_string_literal: true

module Decidim
  module Verifications
    module SalouCensus
      # Custom helpers, scoped to SalouCensus verificator.
      #
      module ApplicationHelper
        def foundation_datepicker_locale_tag
          javascript_include_tag "datepicker-locales/foundation-datepicker.#{I18n.locale}.js" if I18n.locale != :en
        end
      end
    end
  end
end
