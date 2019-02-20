# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'decidim/verifications/salou_census/version'

Gem::Specification.new do |s|
  s.version = Decidim::Verifications::SalouCensus.version
  s.authors = ['MarcReniu']
  s.email = ['marc.rs@coditramuntana.com']
  s.license = 'AGPL-3.0'
  s.homepage = 'https://gitlab.coditdev.net/decidim/decidim-verifications-salou_census'
  s.required_ruby_version = '>= 2.3.1'

  s.name = 'decidim-verifications-salou_census'
  s.summary = 'A decidim Verifications::SalouCensus module'
  s.description = 'Integration with Salou Census verification WS.'

  s.files = Dir['{app,config,lib}/**/*', 'LICENSE-AGPLv3.txt', 'Rakefile', 'README.md']

  DECIDIM_VERSION = '~> 0.16.0'

  s.add_dependency "decidim-core", DECIDIM_VERSION
  s.add_dependency 'decidim-admin', DECIDIM_VERSION
  s.add_dependency 'decidim-verifications', DECIDIM_VERSION
  s.add_dependency 'rails', '>= 5.2'

  s.add_development_dependency 'decidim-dev', DECIDIM_VERSION
end
