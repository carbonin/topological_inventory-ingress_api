require "topological_inventory/ingress_api/messaging_client"

module TopologicalInventory
  module IngressApi
    module V0
      class InventoryController < ApplicationController
        skip_before_action :verify_authenticity_token
        def save_inventory
          payload = JSON.parse(request.body.read)

          retry_count = 0
          retry_max   = 1

          TopologicalInventory::IngressApi.with_messaging_client do |client|
            begin
              client.publish_message(save_inventory_payload(payload))
            rescue Kafka::DeliveryFailed
              retry_count += 1
              retry unless retry_count > retry_max
            end
          end

          render status: 200, :json => {
            :message => "ok",
          }.to_json
        rescue => e
          render :status => 500, :json => {
            :message    => e.message,
            :error_code => e.class.to_s,
          }.to_json

          raise e
        end

        private

        def save_inventory_payload(raw_payload)
          {
            :service => "platform.topological-inventory.persister",
            :message => "save_inventory",
            :payload => raw_payload,
          }
        end
      end
    end
  end
end
