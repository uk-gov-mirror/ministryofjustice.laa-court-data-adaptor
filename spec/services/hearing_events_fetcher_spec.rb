# frozen_string_literal: true

RSpec.describe HearingEventsFetcher do
  subject { described_class.call(hearing_id: hearing_id, hearing_date: hearing_date) }

  let(:hearing_id) { '2c24f897-ffc4-439f-9c4a-ec60c7715cd0' }
  let(:hearing_date) { '2020-04-30' }

  it 'returns the requested hearing info' do
    VCR.use_cassette('hearing_logs_fetcher/success') do
      expect(subject.body['hearingId']).to eq(hearing_id)
    end
  end

  context 'with a incorrect key' do
    let(:connection) { CommonPlatformConnection.call }

    subject { described_class.call(hearing_id: hearing_id, hearing_date: hearing_date, connection: connection) }

    before do
      connection.headers['Ocp-Apim-Subscription-Key'] = 'INCORRECT KEY'
    end

    it 'returns an unauthorised response' do
      VCR.use_cassette('hearing_logs_fetcher/unauthorised') do
        expect(subject.status).to eq(401)
      end
    end
  end

  context 'connection' do
    subject { described_class.call(hearing_id: hearing_id, hearing_date: hearing_date, connection: connection) }

    let(:connection) { double('CommonPlatformConnection') }
    let(:url) { 'LAAGetHearingEventLogHttpTriggerFast' }
    let(:params) { { hearingId: hearing_id, date: hearing_date } }

    it 'makes a get request' do
      expect(connection).to receive(:get).with(url, params)
      subject
    end
  end
end