# frozen_string_literal: true

require 'spec_helper'

describe Decidim::Verifications::SalouCensus::SalouCensusAuthorizationHandler do
  let(:organization) { create(:organization) }
  let(:handler) { described_class.new(params.merge(extra_params)) }
  let(:params) { { user: create(:user, :confirmed, organization: organization) } }
  let(:extra_params) { { document_number: document_number, birthdate: birthdate } }

  let(:document_number) { 'X0000000F' }
  let(:birthdate) { Date.new(1973, 1, 18) }
  let(:ciphed_document_number) { "WDAwMDAwMDBG\n" }
  let(:ciphed_birthdate) { "MTgvMDEvMTk3Mw==\n" }
  let(:verification_code) { '63c98e40a053adf9ea0f80e31ef27efe7ff77ae259f3fa0d47dfdf3ab22efe4ef70b598656dbd4405df61890c3955c050939c1dff7f5d4ffd29a6f85689c1565' }

  describe "metadata" do
    subject { handler.metadata }

    it "should be filled", salou_census_stub_type: :valid do
       is_expected.to eq(document_number: ciphed_document_number, birthdate: ciphed_birthdate, verification_code: verification_code)
    end
  end

  describe "valid?" do
    subject { handler.valid? }

    context "when no document number" do
      let(:document_number) { nil }

      it { is_expected.to eq(false) }
    end

    context "when no birthdate" do
      let(:birthdate) { nil }

      it { is_expected.to eq(false) }
    end

    context "when birthdate is less than 16 years ago" do
      let(:birthdate) { Date.today }

      it { is_expected.to eq(false) }
    end

    context "when using already saved verification data" do
      before do
        create(
          :authorization,
          :granted,
          user: create(:user, :confirmed, organization: organization),
          name: 'salou_census_authorization_handler',
          metadata: { document_number: ciphed_document_number, birthdate: ciphed_birthdate, verification_code: verification_code }
        )
      end

      it { is_expected.to eq(false) }
    end

    context "when all data is valid", salou_census_stub_type: :valid do
      it { is_expected.to eq(true) }
    end
  end

end
