module HmctsCommonPlatform
  class Plea
    attr_reader :data

    def initialize(data)
      @data = data
    end

    def originating_hearing_id
      data[:originatingHearingId]
    end

    def delegated_powers
      HmctsCommonPlatform::DelegatedPowers.new(data[:delegatedPowers]) if data[:delegatedPowers]
    end

    def offence_id
      data[:offenceId]
    end

    def application_id
      data[:applicationId]
    end

    def plea_date
      data[:pleaDate]
    end

    def plea_value
      data[:pleaValue]
    end

    def lesser_or_alternative_offence
      HmctsCommonPlatform::LesserOrAlternativeOffence.new(data[:lesserOrAlternativeOffence]) if data[:lesserOrAlternativeOffence]
    end
  end
end
