# frozen_string_literal: true

require 'decidim/dev'
require 'decidim/admin'
require 'decidim/core'
require 'decidim/verifications'
require 'decidim/core/test'
require 'letter_opener_web'

require 'support/salou_census_authorization_handler_stubs'

ENV['ENGINE_ROOT'] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = File.expand_path(File.join('spec', 'decidim_dummy_app'))

require 'decidim/dev/test/base_spec_helper'

RSpec.configure do |config|
  config.include SalouCensusAuthorizationHandlerStubs
end
