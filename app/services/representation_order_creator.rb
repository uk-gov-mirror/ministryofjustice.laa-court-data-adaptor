# frozen_string_literal: true

class RepresentationOrderCreator < ApplicationService
  def initialize(defendant_id:, offences:, maat_reference:, defence_organisation:)
    @offences = offences.map(&:with_indifferent_access)
    @maat_reference = maat_reference
    @defendant_id = defendant_id
    @defence_organisation = defence_organisation.deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
    sanitise_defence_organisation
  end

  def call
    call_cp_endpoint
  end

  private

  def call_cp_endpoint
    remove_offences_without_status_date

    offences.each do |offence|
      prosecution_case = ProsecutionCaseDefendantOffence.find_by!(defendant_id: defendant_id, offence_id: offence[:offence_id])

      Api::RecordRepresentationOrder.call(
        prosecution_case_id: prosecution_case.prosecution_case_id,
        defendant_id: defendant_id,
        offence_id: offence[:offence_id],
        status_code: offence[:status_code],
        application_reference: maat_reference,
        status_date: offence[:status_date],
        effective_start_date: offence[:effective_start_date],
        effective_end_date: offence[:effective_end_date],
        defence_organisation: defence_organisation
      )
    end
  end

  def remove_offences_without_status_date
    offences.each do |offence|
      offences.delete(offence) if offence[:status_date].present? == false
    end
  end

  def sanitise_defence_organisation
    sanitise_postcode if defence_organisation.dig(:organisation, :address, :postcode)
    sanitise_contact_details
  end

  def sanitise_postcode
    postcode = defence_organisation.dig(:organisation, :address, :postcode)
    defence_organisation[:organisation][:address].delete(:postcode) unless CommonPlatform::PostcodeValidator.new(postcode: postcode).call
  end

  def sanitise_contact_details
    @contact = defence_organisation.dig(:organisation, :contact)
    return unless contact

    sanitise_email_addresses
    sanitise_phone_numbers
  end

  def sanitise_email_addresses
    %i[primaryEmail secondaryEmail].each do |email|
      defence_organisation[:organisation][:contact].delete(email) unless CommonPlatform::EmailValidator.new(email: contact.dig(email)).call
    end
  end

  def sanitise_phone_numbers
    %i[home mobile].each do |number|
      defence_organisation[:organisation][:contact].delete(number) unless CommonPlatform::PhoneValidator.new(phone: contact.dig(number)).call
    end
  end

  attr_reader :defendant_id, :offences, :maat_reference, :defence_organisation, :contact
end
