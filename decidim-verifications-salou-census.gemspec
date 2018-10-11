# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

require 'decidim/verifications/salou_census/version'

Gem::Specification.new do |s|
  s.version = Decidim::Verifications::SalouCensus.version
  s.authors = ['MarcReniu']
  s.email = ['marc.rs@coditramuntana.com']
  s.license = 'AGPL-3.0'
  s.homepage = 'https://github.com/decidim/decidim-module-VerificationsSalouCensus'
  s.required_ruby_version = '>= 2.3.1'

  s.name = 'decidim-verifications-salou_census'
  s.summary = 'A decidim Verifications::SalouCensus module'
  s.description = 'Integration with Salou Census verification WS.'

  s.files = Dir['{app,config,lib}/**/*', 'LICENSE-AGPLv3.txt', 'Rakefile', 'README.md']

  s.add_dependency 'decidim', Decidim::Verifications::SalouCensus.version
  s.add_dependency 'decidim-admin', Decidim::Verifications::SalouCensus.version
  s.add_dependency 'rails', '>= 5.2'

  s.add_development_dependency 'decidim-dev', Decidim::Verifications::SalouCensus.version
  s.add_development_dependency 'faker'
  s.add_development_dependency 'letter_opener_web', '~> 1.3.3'
  s.add_development_dependency 'listen'
end
