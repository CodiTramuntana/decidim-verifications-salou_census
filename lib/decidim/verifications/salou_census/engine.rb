# frozen_string_literal: true

require 'rails'
require 'decidim/core'
require "decidim/verifications"

module Decidim
  module Verifications
    module SalouCensus
      # This is the engine that runs on the public interface of Verifications::SalouCensus.
      class Engine < ::Rails::Engine
        isolate_namespace Decidim::Verifications::SalouCensus
      end
    end
  end
end
