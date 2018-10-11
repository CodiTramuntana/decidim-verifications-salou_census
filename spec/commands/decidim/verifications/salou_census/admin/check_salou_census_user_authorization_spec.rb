# frozen_string_literal: true

require "spec_helper"

describe Decidim::Verifications::SalouCensus::Admin::CheckSalouCensusUserAuthorization do
  subject { described_class.new(authorization, handler) }
  let!(:organization) do
    create(:organization, available_authorizations: ["salou_census"])
  end
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:authorization) do
    create(
      :authorization,
      :granted,
      user: user,
      name: "salou_census",
      metadata: { perscod: "123456", verification_code: "69d778c55bd6355bdf643a5feb9407d0bd5d2af639f68825c079feeca9596e29651970146a3d6f1b86960167d14e274bb89370d494c9e677628dfd51618f715d" }
    )
  end

  let(:authorizations) do
    Decidim::Verifications::Authorizations.new(organization: organization, user: user, granted: true, name: "salou_census")
  end

  let(:handler_class) do
    Decidim::Verifications::SalouCensus::SalouCensusAuthorizationHandler
  end

  let(:handler) { handler_class.from_model(authorization) }

  context "when the authorization is not valid" do
    it "is not valid", salou_census_stub_type: :invalid do
      expect { subject.call }.to broadcast(:invalid)
    end

    it "revoke the authorization for the user", salou_census_stub_type: :invalid do
      expect { subject.call }.to change { authorizations.count }.by(-1)
    end
  end

  context "when check is ok" do
    it "broadcasts ok", salou_census_stub_type: :valid do
      expect { subject.call }.to broadcast(:ok)
    end
  end
end
