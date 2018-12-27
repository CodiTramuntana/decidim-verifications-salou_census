# frozen_string_literal: true

require 'spec_helper'

describe Decidim::Verifications::SalouCensus::ConfirmSalouCensusUserAuthorization do
  subject { described_class.new(authorization, form) }
  let!(:organization) do
    create(:organization, available_authorizations: ['salou_census'])
  end
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:authorization) do
    Decidim::Authorization.new(
      user: user,
      name: 'salou_census',
      metadata: { document_number: "MDAwMDAwMDBU\n", birthdate: "MTgvMDEvMTk3Mw==\n", verification_code: 'f745d59c33d68ad194247e6a2a197e90258da77977605c1a6c421c5df3e384b48f863071f4aa944e08a0be69bec38ca30737da1103578aadd09ca0f9383a9456' }
    )
  end
  let(:document_number) { '00000000T' }

  let(:authorizations) do
    Decidim::Verifications::Authorizations.new(organization: organization, user: user, granted: true, name: 'salou_census')
  end

  let(:form_class) do
    Decidim::Verifications::SalouCensus::SalouCensusForm
  end

  let(:form) { form_class.new(document_number: document_number, birthdate: Date.new(1973, 1, 18), user: user) }

  context 'when the form is not valid' do
    let!(:document_number) { '123' }

    it 'is not valid' do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context 'when the authorization is already confirmed' do
    before { authorization.grant! }
    it 'broadcasts already confirmed' do
      expect { subject.call }.to broadcast(:already_confirmed)
    end
  end

  context 'when everything is ok' do
    it 'broadcasts ok', salou_census_stub_type: :valid do
      expect { subject.call }.to broadcast(:ok)
    end

    it 'confirms the authorization for the user', salou_census_stub_type: :valid do
      expect { subject.call }.to change { authorizations.count }.by(1)
    end
  end
end
