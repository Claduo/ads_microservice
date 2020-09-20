require "amazing_print"
Application.configure do |app|
  logger = Ougai::Logger.new(
      app.root.concat("/", Settings.logger.path),
      level: Settings.logger.level
  )
  # Попробовал, не очень понравилось, потом поиграюсь в настройках
  # logger.formatter = Ougai::Formatters::Readable.new if Application.environment == :development

  logger.before_log = lambda do |data|
    data[:service] = { name: Settings.app.name }
    data[:request_custom_data] ||= { id: Thread.current[:request_id] }
  end
  app.set :logger, logger
end

Sequel::Model.db.loggers.push(Application.logger)