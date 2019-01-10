# frozen_string_literal: true

require 'spec_helper'

describe Decidim::Verifications::SalouCensus::Admin::CheckSalouCensusUserAuthorization do
  subject { described_class.new(authorization, handler) }
  let!(:organization) do
    create(:organization, available_authorizations: ['salou_census_authorization_handler'])
  end
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:authorization) do
    create(
      :authorization,
      :granted,
      user: user,
      name: 'salou_census_authorization_handler',
      metadata: { document_number: "MDAwMDAwMDBU\n", birthdate: "MTgvMDEvMTk3Mw==\n", verification_code: 'f745d59c33d68ad194247e6a2a197e90258da77977605c1a6c421c5df3e384b48f863071f4aa944e08a0be69bec38ca30737da1103578aadd09ca0f9383a9456' }
    )
  end

  let(:authorizations) do
    Decidim::Verifications::Authorizations.new(organization: organization, user: user, granted: true, name: 'salou_census_authorization_handler')
  end

  let(:handler_class) do
    Decidim::Verifications::SalouCensus::SalouCensusAuthorizationHandler
  end

  let(:handler) { handler_class.from_model(authorization) }

  context 'when the authorization is not valid' do
    it 'is not valid', salou_census_stub_type: :invalid do
      expect { subject.call }.to broadcast(:invalid)
    end

    it 'revoke the authorization for the user', salou_census_stub_type: :invalid do
      expect { subject.call }.to change { authorizations.count }.by(-1)
    end
  end

  context 'when check is ok' do
    it 'broadcasts ok', salou_census_stub_type: :valid do
      expect { subject.call }.to broadcast(:ok)
    end
  end
end
