# frozen_string_literal: true

module Api
  module Internal
    module V1
      class DefendantsController < ApplicationController
        def update
          contract = UnlinkDefendantContract.new.call(**transformed_params)
          if contract.success?
            enqueue_unlink
            render status: :accepted
          else
            render json: contract.errors.to_hash, status: :bad_request
          end
        end

        private

        def enqueue_unlink
          UnlinkLaaReferenceWorker.perform_async(
            Current.request_id,
            transformed_params[:defendant_id],
            transformed_params[:user_name],
            transformed_params[:unlink_reason_code],
            transformed_params[:unlink_reason_text]
          )
        end

        def unlink_params
          params.from_jsonapi.require(:defendant).permit(allowed_params)
        end

        def allowed_params
          %i[user_name unlink_reason_code unlink_reason_text]
        end

        def transformed_params
          @transformed_params ||= unlink_params.slice(*allowed_params).to_hash.transform_keys(&:to_sym).merge(defendant_id: params[:id])
        end
      end
    end
  end
end
