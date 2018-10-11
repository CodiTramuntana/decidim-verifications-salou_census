# frozen_string_literal: true

require 'digest'

module Decidim
  module Verifications
    module SalouCensus
      class SalouCensusFormatter
        FIELDS = %i[document_number birthdate].freeze

        def initialize(type, values = {})
          @type = type
          @values = values
          @data = {
            document_number: nil,
            birthdate: nil
          }
        end

        def data
          fill_data
          @data.clone
        end

        private

        def fill_data
          FIELDS.each do |field|
            @data[field] = value_by_type(field)
          end
        end

        def value_by_type(field)
          send(:"value_for_#{@type}_type", field)
        end

        def value_for_form_type(field)
          value = case field
                  when :document_number
                    format_data_for_value(@values[:document_number])
                  when :birthdate
                    format_data_for_date(@values[:birthdate])
                  end
          value
        end

        def value_for_salou_census_type(field)
          value = case field
                  when :document_number
                    format_data_for_value(@values[:document_number])
                  when :birthdate
                    format_data_for_date(@values[:birthdate])
                  end
          value
        end

        def format_data_for_date(value)
          if [Date, DateTime, Time].include?(value.class)
            value.strftime('%d/%m/%Y')
          else
            value
          end
        end

        def format_data_for_value(value)
          value.upcase
        end
      end
    end
  end
end
