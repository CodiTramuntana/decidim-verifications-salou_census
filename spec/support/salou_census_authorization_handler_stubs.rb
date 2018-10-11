# frozen_string_literal: true

module SalouCensusAuthorizationHandlerStubs
  def stub_valid_response
    stub_request(:post, URI.parse(salou_census_url))
      .with(headers: { "Content-Type": 'text/xml' })
      .to_return(status: 200, body: File.open(File.dirname(__FILE__) + '/fixtures/salou_census_valid_response.xml', 'rb').read)
  end

  def stub_invalid_response
    stub_request(:post, URI.parse(salou_census_url))
      .with(headers: { "Content-Type": 'text/xml' })
      .to_return(status: 200, body: File.open(File.dirname(__FILE__) + '/fixtures/salou_census_invalid_response.xml', 'rb').read)
  end

  def stub_error_response
    stub_request(:post, URI.parse(salou_census_url))
      .with(headers: { "Content-Type": 'text/xml' })
      .to_return(status: 400)
  end

  private

  def salou_census_url
    Decidim::Verifications::SalouCensus::SalouCensusAuthorizationConfig.url
  end
end

RSpec.configure do |config|
  config.before salou_census_stub_type: :valid do
    stub_valid_response
  end
  config.before salou_census_stub_type: :invalid do
    stub_invalid_response
  end
  config.before salou_census_stub_type: :error do
    stub_error_response
  end
end
