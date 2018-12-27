# frozen_string_literal: true

require 'digest'

module Decidim
  module Verifications
    module SalouCensus
      class SalouCensusDigest
        FIELDS = %i[document_number birthdate].freeze

        def initialize(type, data = {})
          @data = SalouCensusFormatter.new(type, data).data
        end

        def generate
          return nil unless valid_data?

          create_digest
        end

        private

        def valid_data?
          return false unless @data.is_a?(Hash)

          FIELDS.each do |field|
            return false if @data[field].blank?
          end
          true
        end

        def create_digest
          data_string = ''
          FIELDS.each do |field|
            data_string += @data[field]
          end
          data_string += Decidim::Verifications::SalouCensus::SalouCensusAuthorizationConfig.secret
          digest(data_string)
        end

        def digest(data_string)
          Digest::SHA512.hexdigest(data_string)
        end
      end
    end
  end
end
