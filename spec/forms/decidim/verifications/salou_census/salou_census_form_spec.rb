# frozen_string_literal: true

require 'spec_helper'

module Decidim
  module Verifications
    module SalouCensus
      describe SalouCensusForm do
        subject do
          described_class.new(document_number: document_number, birthdate: birthdate)
        end

        let(:user) { create(:user) }

        let(:document_number) { 'X0000000F' }
        let(:birthdate) { Date.new(1973, 1, 18) }

        context 'when the data is valid with NIE' do
          it 'is valid', salou_census_stub_type: :valid do
            expect(subject).to be_valid
          end
        end

        context 'when the data is valid with DNI' do
          let(:document_number) { '00000000T' }

          it 'is valid', salou_census_stub_type: :valid do
            expect(subject).to be_valid
            expect(subject).to have_attributes(metadata: { document_number: "MDAwMDAwMDBU\n", birthdate: "MTgvMDEvMTk3Mw==\n", verification_code: 'f745d59c33d68ad194247e6a2a197e90258da77977605c1a6c421c5df3e384b48f863071f4aa944e08a0be69bec38ca30737da1103578aadd09ca0f9383a9456' })
          end
        end

        context 'when the document number format is invalid' do
          let(:document_number) { 'XXXXXXXX-Y' }

          it 'is not valid' do
            expect(subject).not_to be_valid
            expect(subject.errors[:document_number])
              .to include('Not valid DNI/NIE. Must be all uppercase, contain only letters and/or numbers, and start with a number or letters X, Y or Z.')
          end
        end

        context 'when the birthdate is blank' do
          let(:birthdate) { '' }

          it 'is not valid' do
            expect(subject).not_to be_valid
            expect(subject.errors[:birthdate])
              .to include("can't be blank")
          end
        end
      end
    end
  end
end
