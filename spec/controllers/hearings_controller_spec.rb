# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HearingsController, type: :controller do
  let(:valid_attributes) { JSON.parse(file_fixture('valid_hearing.json').read) }
  let(:invalid_attributes) { JSON.parse(file_fixture('invalid_hearing.json').read) }

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Hearing' do
        expect {
          post :create, params: valid_attributes
        }.to change(Hearing, :count).by(1)
      end

      it 'renders a JSON response with the new hearing' do
        post :create, params: valid_attributes
        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the new hearing' do
        post :create, params: invalid_attributes
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
