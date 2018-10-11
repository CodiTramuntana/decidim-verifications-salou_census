# frozen_string_literal: true

module Decidim
  module Verifications
    module SalouCensus
      class SalouCensusAuthorizationHandler < Decidim::AuthorizationHandler
        attribute :verification_code, String
        attribute :perscod, String

        def handler_name
          "salou_census"
        end

        def map_model(model)
          self.verification_code = model.metadata.try(:[], "verification_code")
          self.perscod = model.metadata.try(:[], "perscod")
        end

        # Checks the response of SalouCensus WS, and add errors in bad cases
        #
        # Returns a boolean
        def salou_census_valid?
          return false if errors.any? || response.blank?
          if success_response?
            unless census_exist?
              errors.add(:base, I18n.t("errors.messages.salou_census.not_valid"))
            end
          else
            errors.add(:base, I18n.t("errors.messages.salou_census.cannot_validate"))
          end
          errors.empty?
        end

        # Generates a verification_code to check it with the saved one
        # Digest is made with SalouCensus response
        #
        # Returns a boolean
        def verification_code_valid?
          old_verification_code = verification_code
          old_verification_code == generate_sanitized_verification_code
        end

        def metadata
          generate_sanitized_verification_code
          {
            perscod: sanitize_perscod,
            verification_code: verification_code
          }
        end

        private

        # Check for WS needed values
        #
        # Returns a boolean
        def uncomplete_credentials?
          perscod.blank?
        end

        # Prepares and perform WS request.
        # It rescue failed connections to SalouCensus
        #
        # Returns an stringified XML
        def response
          return nil if uncomplete_credentials?

          return @response if already_processed?
          begin
            response ||= Faraday.post(SalouCensusAuthorizationConfig.url, request_body, "content-type": "text/xml")
            @response ||= {
              body: response.body,
              status: response.status
            }
          rescue Faraday::ConnectionFailed
            errors.add(:base, I18n.t("errors.messages.salou_census.connection_failed"))
            return nil
          rescue Faraday::TimeoutError
            errors.add(:base, I18n.t("errors.messages.salou_census.connection_timeout"))
            return nil
          end
        end

        # Creates WS request body, using SalouCensus config data, and user's perscod
        #
        # Returns a XML string
        def request_body
          @request_body ||= <<~XML
            <e>
              <ope>
                <apl>PAD</apl>
                <tobj>HAB</tobj>
                <cmd>CONSULTAESTADO</cmd>
                <ver>2.0</ver>
              </ope>
              <sec>
                <cli>#{SalouCensusAuthorizationConfig.param(:cli)}</cli>
                <org>#{SalouCensusAuthorizationConfig.param(:org)}</org>
                <ent>#{SalouCensusAuthorizationConfig.param(:ent)}</ent>
                <usu>#{SalouCensusAuthorizationConfig.param(:usu)}</usu>
                <pwd>#{SalouCensusAuthorizationConfig.param(:pwd)}</pwd>
                <fecha>#{SalouCensusAuthorizationConfig.param(:fecha)}</fecha>
                <nonce>#{SalouCensusAuthorizationConfig.param(:nonce)}</nonce>
                <token>#{SalouCensusAuthorizationConfig.param(:token)}</token>
              </sec>
              <par>
                <codigoHabitante>#{perscod}</codigoHabitante>
                <busquedaExacta>-1</busquedaExacta>
              </par>
            </e>
          XML
        end

        # Retrieve the Nokogiri of WS response, for better use
        #
        # Returns an XML
        def sanitize_response
          @sanitize_response ||= Nokogiri::XML(response[:body]).xpath("//s//par")
        end

        # Retrieve documento value of WS response
        #
        # Returns a String
        def sanitize_nif
          @sanitize_nif ||= sanitize_response.xpath("//documento").text
        end

        # Retrieve persndata value of WS response
        #
        # Returns a String
        def sanitize_birthdate
          @sanitize_birthdate ||= sanitize_response.xpath("//fechaNacimiento").text
        end

        # Retrieve codigoHabitante value of WS response
        #
        # Returns a String
        def sanitize_perscod
          @sanitize_perscod ||= sanitize_response.xpath("//codigoHabitante").text
        end

        # Check if request had benn already been processed and saved
        #
        # Returns a boolean
        def already_processed?
          defined?(@response)
        end

        # Check if request had been correctly performed
        #
        # Returns a boolean
        def success_response?
          # Status code 200, success request. Otherwise, error
          response[:status] == 200
        end

        # Check if WS response carries user data
        # If not, it is considered that user do not exists in SalouCensus system
        #
        # Returns a boolean
        def census_exist?
          # response with empty data, user data is not in census
          sanitize_response.children.present?
        end

        # Generate a verification_code with SalouCensusDigest lib, using WS response
        #
        # Returns the verification_code as String
        def generate_sanitized_verification_code
          self.verification_code = SalouCensusDigest.new("salou_census", salou_census_data_attributes).generate
        end

        def salou_census_data_attributes
          {
            document_number: sanitize_nif,
            birthdate: sanitize_birthdate
          }
        end
      end
    end
  end
end
