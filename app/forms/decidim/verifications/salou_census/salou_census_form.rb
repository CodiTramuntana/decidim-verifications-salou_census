# frozen_string_literal: true

module Decidim
  module Verifications
    module SalouCensus
      # A form object to be used when public users want to get verified by
      # Salou Census verificator
      class SalouCensusForm < SalouCensusAuthorizationHandler
        DOCUMENT_NUMBER_REGEXP = /\A[XYZ0-9]{1}[0-9]{7}[A-Z]{1}/

        attribute :document_number, String
        attribute :birthdate, Date
        attribute :persisted, Decidim::Authorization

        validates :birthdate, presence: true
        validates :document_number,
                  format: { with: DOCUMENT_NUMBER_REGEXP, message: I18n.t("errors.messages.salou_census.not_valid_dni_or_nie") },
                  presence: true

        # Generates a verification code, with Form data. Then proceed to check if
        # it already exists in DB, or correspond with related authorization
        #
        # Returns a boolean
        def check_verification_code
          generate_verification_code
          persisted.present? ? check_own_verification_code : check_other_verification_code
          errors.empty?
        end

        private

        # Generate a verification_code with SalouCensusDigest lib, using form data
        #
        # Returns the verification_code as String
        def generate_verification_code
          self.verification_code = SalouCensusDigest.new("form", form_data_attributes).generate
        end

        # For new authorizations, we check that no other one has the same verification_code
        # It is scoped with current_user organization
        #
        # Returns nothing
        def check_other_verification_code
          authorizations = Authorizations.new(organization: user.organization, name: "salou_census")
                                         .query
                                         .where.not(user: user)
                                         .where(%(metadata @> '{"verification_code": "#{verification_code}"}'))

          errors.add(:base, I18n.t("errors.messages.salou_census.duplicated")) if authorizations.any?
        end

        # For reverifications, Form data must be as equal as saved in Authorization
        #
        # Returns nothing
        def check_own_verification_code
          errors.add(:base, I18n.t("errors.messages.salou_census.not_correspond")) unless persisted.verification_code == verification_code
        end

        # Check for WS needed values
        #
        # Returns a boolean
        def uncomplete_credentials?
          sanitize_document_number.blank? || sanitize_birthdate.blank?
        end

        # Overwritte method, it uses document_number and birthdate, instead of perscod value
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
                <documento>#{sanitize_document_number}</documento>
                <fechaNacimiento>#{sanitize_birthdate}</fechaNacimiento>
                <busquedaExacta>-1</busquedaExacta>
              </par>
            </e>
          XML
        end

        # Document number parameter, as String
        #
        # Returns a String
        def sanitize_document_number
          @sanitize_document_number ||= document_number&.to_s
        end

        # Birthdate must be in a DD/MM/YYYY format to be accepted for the WS
        #
        # Returns a String
        def sanitize_birthdate
          @sanitize_birthdate ||= birthdate&.strftime("%d/%m/%Y")
        end

        def form_data_attributes
          {
            document_number: document_number,
            birthdate: birthdate
          }
        end
      end
    end
  end
end
