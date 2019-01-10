# frozen_string_literal: true

require 'spec_helper'

describe 'Salou Census verification request', type: :system do
  let!(:organization) do
    create(:organization, available_authorizations: ['salou_census_authorization_handler'])
  end
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:user2) { create(:user, :confirmed, organization: organization) }
  let!(:authorization) do
    create(
      :authorization,
      :granted,
      user: user2,
      name: 'salou_census_authorization_handler',
      metadata: { verification_code: '69d778c55bd6355bdf643a5feb9407d0bd5d2af639f68825c079feeca9596e29651970146a3d6f1b86960167d14e274bb89370d494c9e677628dfd51618f715d' }
    )
  end

  let!(:valid_salou_census) do
    {
      document_number: 'X0000000F',
      birthdate: Date.new(1973, 1, 18)
    }
  end
  let!(:invalid_salou_census) do
    {
      document_number: '',
      birthdate: Date.today
    }
  end

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit decidim_verifications.new_authorization_path(handler: "salou_census_authorization_handler")
  end

  it 'redirects to verification after login' do
    expect(page).to have_content('Verify with Salou Census')
  end

  it 'allows the user to fill up form field', salou_census_stub_type: :valid do
    submit_salou_census_form(
      document_number: valid_salou_census[:document_number],
      birthdate: valid_salou_census[:birthdate]
    )

    expect(page).to have_current_path decidim_verifications.authorizations_path
    expect(page).to have_content("You've been successfully authorized")
  end

  it 'shows an error when data is not valid' do
    submit_salou_census_form(
      document_number: invalid_salou_census[:document_number],
      birthdate: invalid_salou_census[:birthdate]
    )
    expect(page).to have_content("There's an error in this field")

    submit_salou_census_form(
      document_number: valid_salou_census[:document_number],
      birthdate: invalid_salou_census[:birthdate]
    )
    expect(page).to have_content('You must be at least 16 years old')
  end

  it 'shows an error when data is not valid in Salou Census', salou_census_stub_type: :invalid do
    submit_salou_census_form(
      document_number: valid_salou_census[:document_number],
      birthdate: valid_salou_census[:birthdate]
    )

    expect(page).to have_content('Your data do not correspond to the census')
  end

  it 'does not submit when data is not fulfilled' do
    submit_salou_census_form(
      document_number: '',
      birthdate: ''
    )

    expect(page).to have_current_path decidim_verifications.new_authorization_path(handler: "salou_census_authorization_handler")
  end

  it 'with same verification data should fail' do
    submit_salou_census_form(
      document_number: '00000000T',
      birthdate: Date.new(1970, 1, 1)
    )
    expect(page).to have_content('These data have already been used')
  end

  private

  def submit_salou_census_form(document_number:, birthdate:)
    fill_in 'Document number', with: document_number
    fill_in 'Birthdate', with: birthdate

    click_button 'Send'
  end
end
