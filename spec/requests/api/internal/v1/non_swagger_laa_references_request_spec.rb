# frozen_string_literal: true

RSpec.describe 'Api::Internal::V1::LaaReferences', type: :request do
  include AuthorisedRequestHelper

  let(:valid_body) do
    {
      data: {
        type: 'laa_references',
        attributes: {
          maat_reference: maat_reference
        },
        relationships: {
          defendant: {
            data: {
              type: 'defendants',
              id: defendant_id
            }
          }
        }
      }
    }
  end
  let(:fragment) { '#/definitions/laa_reference/definitions/new_resource' }
  let(:maat_reference) { 1_231_231 }
  let(:prosecution_case_id) { SecureRandom.uuid }
  let(:defendant_id) { SecureRandom.uuid }
  let(:mock_laa_reference_creator_job) { double LaaReferenceCreatorJob }

  before do
    allow(LaaReferenceCreatorJob).to receive(:new).and_return(mock_laa_reference_creator_job)
    allow(mock_laa_reference_creator_job).to receive(:enqueue)
  end

  subject { post api_internal_v1_laa_references_path, params: valid_body, headers: valid_auth_header }

  describe 'POST /api/internal/v1/laa_references' do
    let(:headers) { valid_auth_header }

    it 'matches the given schema' do
      expect(valid_body).to be_valid_against_schema(fragment: fragment)
    end

    it 'returns an accepted status' do
      subject
      expect(response).to have_http_status(202)
    end

    it 'creates an laa_reference_creator job' do
      expect(mock_laa_reference_creator_job).to receive(:enqueue).once
      subject
    end

    context 'with an invalid maat_reference' do
      let(:maat_reference) { 'ABC123123' }

      it 'returns a bad_request status' do
        subject
        expect(response).to have_http_status(400)
      end
    end

    context 'with a blank maat_reference' do
      before { valid_body[:data][:attributes].delete(:maat_reference) }

      it 'returns an accepted status' do
        subject
        expect(response).to have_http_status(202)
      end
    end
  end
end
