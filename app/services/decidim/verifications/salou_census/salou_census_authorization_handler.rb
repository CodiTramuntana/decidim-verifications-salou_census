# frozen_string_literal: true

module Decidim
  module Verifications
    module SalouCensus
      class SalouCensusAuthorizationHandler < Decidim::AuthorizationHandler
        attribute :verification_code, String
        attribute :document_number, String
        attribute :birthdate, String

        def handler_name
          'salou_census'
        end

        def map_model(model)
          self.verification_code = model.metadata.try(:[], 'verification_code')
          self.document_number = decipherData(model.metadata.try(:[], 'document_number'))
          self.birthdate = decipherData(model.metadata.try(:[], 'birthdate'))
        end

        # Checks the response of SalouCensus WS, and add errors in bad cases
        #
        # Returns a boolean
        def salou_census_valid?
          return false if errors.any? || response.blank?

          if success_response?
            unless census_exist?
              errors.add(:base, I18n.t('errors.messages.salou_census.not_valid'))
            end
          else
            errors.add(:base, I18n.t('errors.messages.salou_census.cannot_validate'))
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
            document_number: cipherData(sanitize_document_number),
            birthdate: cipherData(sanitize_birthdate),
            verification_code: verification_code
          }
        end

        private

        # Check for WS needed values
        #
        # Returns a boolean
        def uncomplete_credentials?
          document_number.blank? && birthdate.blank?
        end

        # Prepares and perform WS request.
        # It rescue failed connections to SalouCensus
        #
        # Returns an stringified XML
        def response
          return nil if uncomplete_credentials?

          return @response if already_processed?

          begin
            response ||= Faraday.post do |request|
              request.url SalouCensusAuthorizationConfig.url
              request.headers['Content-Type'] = 'text/xml'
              request.headers['SOAPAction'] = 'ISHABITANTE'
              request.body = request_body
            end
            @response ||= {
              body: response.body,
              status: response.status
            }
          rescue Faraday::ConnectionFailed
            errors.add(:base, I18n.t('errors.messages.salou_census.connection_failed'))
            return nil
          rescue Faraday::TimeoutError
            errors.add(:base, I18n.t('errors.messages.salou_census.connection_timeout'))
            return nil
          end
        end

        # Creates WS request body, using SalouCensus config data, and user's document_number
        #
        # Returns a XML string
        def request_body
          @request_body ||= <<~XML
            <soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ci="http://ci.sw.aytos">
              <soapenv:Header/>
              <soapenv:Body>
                <ci:servicio soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
                  <in0 xsi:type="soapenc:string" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/">
                    <![CDATA[
                      <e>
                        <ope>
                          <apl>PAD</apl>
                          <tobj>HAB</tobj>
                          <cmd>ISHABITANTE</cmd>
                          <ver>2.0</ver>
                        </ope>
                        <sec>
                          <cli>#{SalouCensusAuthorizationConfig.param(:cli)}</cli>
                          <org>#{SalouCensusAuthorizationConfig.param(:org)}</org>
                          <ent>#{SalouCensusAuthorizationConfig.param(:ent)}</ent>
                          <usu>#{SalouCensusAuthorizationConfig.param(:usu)}</usu>
                          <pwd>#{SalouCensusAuthorizationConfig.param(:pwd)}</pwd>
                          <fecha>#{request_params[:fecha]}</fecha>
                          <nonce>#{request_params[:nonce]}</nonce>
                          <token>#{request_params[:token]}</token>
                        </sec>
                        <par>
                          <codigoTipoDocumento>1</codigoTipoDocumento>
                          <documento>#{cipherData(sanitize_document_number)}</documento>
                          <mostrarFechaNac>-1</mostrarFechaNac>
                        </par>
                      </e>
                    ]]>
                  </in0>
                </ci:servicio>
              </soapenv:Body>
            </soapenv:Envelope>
          XML
        end

        # Creates a Base64 String from a String
        #
        # Return a String
        def cipherData(data)
          return '' unless data

          Base64.encode64(data)
        end

        # Creates a String from a Base64 String
        #
        # Return a String
        def decipherData(data)
          return '' unless data

          Base64.decode64(data)
        end

        # Creates WS request params
        #
        # Return a Hash
        def request_params
          fecha = Time.now.strftime('%Y%m%d%H%M%S')
          nonce = rand(1_000_000_000_000).to_s
          key = SalouCensusAuthorizationConfig.param(:key)
          token = Digest::SHA512.base64digest(nonce + fecha + key)
          @request_params ||= {
            fecha: fecha,
            nonce: nonce,
            token: token
          }
        end

        # Retrieve the Nokogiri of WS response, for better use
        #
        # Returns an XML
        def sanitize_response
          @sanitize_response ||= Nokogiri::XML(
            Nokogiri::XML(response[:body]).xpath('soapenv:Envelope//soapenv:Body//servicioReturn').children.text
          )
        end

        # Document number parameter, as String
        #
        # Returns a String
        def sanitize_document_number
          @sanitize_document_number ||= document_number&.to_s
        end

        # Birthdate must be in a DD/MM/YYYY format
        #
        # Returns a String
        def sanitize_birthdate
          @sanitize_birthdate ||= birthdate&.to_s
        end

        # Retrieve isHabitante value of WS response
        #
        # Returns a Integer
        def sanitize_is_habitante
          @sanitize_is_habitante ||= sanitize_response.xpath('//isHabitante').text.to_i
        end

        # Retrieve fechaNacimiento value of WS response
        #
        # Returns a date String in a DD/MM/YYYY format
        def sanitize_fecha_nacimiento
          @sanitize_fecha_nacimiento ||= sanitize_response.xpath('//fechaNacimiento').text.to_date.strftime('%d/%m/%Y')
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

        # Check if WS response carries correct data
        # If not, it is considered that user do not exists or it's incorrect
        # in SalouCensus system
        #
        # Returns a boolean
        def census_exist?
          # response with `isHabitante` value lower than 0, user data is in census
          sanitize_is_habitante < 0 && sanitize_birthdate == sanitize_fecha_nacimiento
        end

        # Generate a verification_code with SalouCensusDigest lib, using WS response
        #
        # Returns the verification_code as String
        def generate_sanitized_verification_code
          # raise
          self.verification_code = SalouCensusDigest.new('salou_census', salou_census_data_attributes).generate
        end

        def salou_census_data_attributes
          {
            document_number: sanitize_document_number,
            birthdate: sanitize_fecha_nacimiento
          }
        end
      end
    end
  end
end
