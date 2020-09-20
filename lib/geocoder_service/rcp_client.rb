require 'dry/initializer'
require_relative 'rpc_api'

module GeocoderService
  class RpcClient
    extend Dry::Initializer[undefined: false]
    include RpcApi

    option :queue, default: proc { create_queue }

    private

    def create_queue
      channel = RabbitMq.channel
      channel.queue('geocoding', durable: true)
    end

    def publish(payload, options = {})
      @queue.publish(
          payload,
          options.merge(
              persistent: true,
              app_id: Settings.app.name,
              headers: {
                  request_id: Thread.current[:request_id]
              }
          )
      )
    end
  end
end