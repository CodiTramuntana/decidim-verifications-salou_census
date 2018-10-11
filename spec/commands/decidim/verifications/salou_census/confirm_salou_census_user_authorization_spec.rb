# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::SalouCensus::ConfirmSalouCensusUserAuthorization do
  subject { described_class.new(authorization, form) }
  let!(:organization) do
    create(:organization, available_authorizations: ["salou_census"])
  end
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:authorization) do
    Decidim::Authorization.new(
      user: user,
      name: "salou_census",
      metadata: { perscod: "123456", verification_code: "69d778c55bd6355bdf643a5feb9407d0bd5d2af639f68825c079feeca9596e29651970146a3d6f1b86960167d14e274bb89370d494c9e677628dfd51618f715d" }
    )
  end
  let(:document_number) { "00000000T" }

  let(:authorizations) do
    Decidim::Verifications::Authorizations.new(organization: organization, user: user, granted: true, name: "salou_census")
  end

  let(:form_class) do
    Decidim::Verifications::SalouCensus::SalouCensusForm
  end

  let(:form) { form_class.new(document_number: document_number, birthdate: Date.new(1970, 1, 1), user: user) }

  context "when the form is not valid" do
    let!(:document_number) { "123" }

    it "is not valid" do
      expect { subject.call }.to broadcast(:invalid)
    end
  end

  context "when the authorization is already confirmed" do
    before { authorization.grant! }
    it "broadcasts already confirmed" do
      expect { subject.call }.to broadcast(:already_confirmed)
    end
  end

  context "when everything is ok" do
    it "broadcasts ok", salou_census_stub_type: :valid do
      expect { subject.call }.to broadcast(:ok)
    end

    it "confirms the authorization for the user", salou_census_stub_type: :valid do
      expect { subject.call }.to change { authorizations.count }.by(1)
    end
  end
end
