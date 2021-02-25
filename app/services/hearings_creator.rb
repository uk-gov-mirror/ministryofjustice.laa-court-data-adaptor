# frozen_string_literal: true

class HearingsCreator < ApplicationService
  def initialize(hearing_id:)
    @hearing_id = hearing_id
    @hearing = hearing_body[:hearing]
    @shared_time = hearing_body[:sharedTime]
  end

  # This is temp to process failing delayed jobs. To be reverted. See PR
  def hearing_body
    body = Hearing.find(@hearing_id).body

    if body.is_a?(Hash)
      return body.deep_symbolize_keys
    end

    if body.is_a?(String)
      JSON.parse(body).deep_symbolize_keys
    end
  end

  def call
    push_prosecution_cases
    push_appeals
  end

private

  def push_prosecution_cases
    hearing[:prosecutionCases]&.each do |prosecution_case|
      prosecution_case[:defendants].each do |defendant|
        next if defendant[:offences].map { |offence| offence.dig(:laaApplnReference, :applicationReference)&.start_with?("A", "Z") }.any?

        push_to_sqs(shared_time: shared_time,
                    case_urn: prosecution_case[:prosecutionCaseIdentifier][:caseURN],
                    defendant: defendant,
                    appeal_data: nil)
      end
    end
  end

  def push_appeals
    hearing[:courtApplications]&.each do |appeal|
      defendant = appeal.dig(:applicant, :defendant)
      next if defendant[:offences].map { |offence| offence.dig(:laaApplnReference, :applicationReference)&.start_with?("A", "Z") }.any?

      push_to_sqs(shared_time: shared_time,
                  case_urn: appeal[:applicationReference],
                  defendant: defendant,
                  appeal_data: {
                    appeal_type: appeal.dig(:type, :applicationCode),
                    appeal_outcome: appeal[:applicationOutcomes],
                  })
    end
  end

  def push_to_sqs(shared_time:, case_urn:, defendant:, appeal_data:)
    Sqs::PublishHearing.call(shared_time: shared_time,
                             jurisdiction_type: jurisdiction_type,
                             case_urn: case_urn,
                             defendant: defendant,
                             court_centre_id: hearing[:courtCentre][:id],
                             appeal_data: appeal_data)
  end

  def jurisdiction_type
    @jurisdiction_type ||= hearing[:jurisdictionType]
  end

  attr_reader :shared_time, :hearing
end
