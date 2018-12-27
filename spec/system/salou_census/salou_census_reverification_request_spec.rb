# frozen_string_literal: true

require 'spec_helper'

describe 'Salou Census verification request', type: :system do
  let!(:organization) do
    create(:organization, available_authorizations: ['salou_census'])
  end
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:authorization) do
    create(
      :authorization,
      :pending,
      user: user,
      name: 'salou_census',
      metadata: { document_number: "MDAwMDAwMDBU\n", birthdate: "MTgvMDEvMTk3Mw==\n", verification_code: 'f745d59c33d68ad194247e6a2a197e90258da77977605c1a6c421c5df3e384b48f863071f4aa944e08a0be69bec38ca30737da1103578aadd09ca0f9383a9456' }
    )
  end

  let!(:salou_census_data) do
    {
      document_number: '00000000T',
      birthdate: Date.new(1973, 1, 18)
    }
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_salou_census.edit_authorization_path
  end

  it 'shows an error when data do not correspond with the previous verification' do
    submit_salou_census_form(
      document_number: '01010101F',
      birthdate: salou_census_data[:birthdate]
    )

    expect(page).to have_content('These data do not correspond with the previous verification')
  end

  it 'allows the user to reverificate himself', salou_census_stub_type: :valid do
    submit_salou_census_form(
      document_number: salou_census_data[:document_number],
      birthdate: salou_census_data[:birthdate]
    )

    expect(page).to have_current_path decidim_verifications.authorizations_path
    expect(page).to have_content('Salou Census verification requested successfully')
  end

  private

  def submit_salou_census_form(document_number:, birthdate:)
    fill_in 'DNI/NIE', with: document_number
    if birthdate.presence
      page.execute_script(%{$("#date_field_salou_census_birthdate").fdatepicker("update", "#{birthdate.strftime('%d/%m/%Y')}")})
      page.execute_script(%{$("#date_field_salou_census_birthdate").trigger({type: "changeDate", date: "#{birthdate.strftime('%Y/%m/%d')}"})})
    end

    click_button 'Request verification'
  end
end
