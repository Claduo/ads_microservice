require 'dry/initializer'
require_relative 'rpc_api'

module AuthService
  class RpcClient
    extend Dry::Initializer[undefined: false]
    include RpcApi

    option :queue, default: proc { create_queue }
    option :reply_queue, default: proc { create_reply_queue }

    option :lock, default: proc { Mutex.new }
    option :condition, default: proc { ConditionVariable.new }

    def self.fetch
      Thread.current['auth_service.rpc_client'] ||= new.start
    end

    def start
      @reply_queue.subscribe do |delivery_info, properties, payload|
        if properties[:correlation_id] == @correlation_id
          @reply_result = JSON.parse(payload)
          @lock.synchronize { @condition.signal }
        end
      end
      self
    end

    private

    attr_writer :correlation_id

    def create_queue
      channel = RabbitMq.channel
      channel.queue('auth', durable: true)
    end

    def create_reply_queue
      channel = RabbitMq.channel
      channel.queue('amq.rabbitmq.reply-to')
    end

    def publish(payload, options = {})
      self.correlation_id = SecureRandom.uuid

      @lock.synchronize do
        @queue.publish(
            payload,
            options.merge(
                reply_to: @reply_queue.name,
                correlation_id: @correlation_id,
                app_id: 'ads_microservice')
        )
        @condition.wait(@lock)
        @reply_result['user_id']
      end
    end
  end
end
