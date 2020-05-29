# frozen_string_literal: true

class HearingEvent
  include ActiveModel::Model

  attr_accessor :body

  def id
    body['hearingEventId']
  end

  def description
    body['recordedLabel']
  end
end