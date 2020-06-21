# frozen_string_literal: true

module ApplicationLoader
  extend self

  def load_app!
    require_app
    init_app
  end

  private

  def require_app
    require_file 'config/application'
  end

  def init_app
    require_dir 'config/initializers'
  end

  def require_file(path)
    full_path = File.join(root, path)
    require full_path
  end

  def require_dir(path)
    full_path = File.join(root, path)
    Dir["#{full_path}/**/*.rb"].each { |file| require file}
  end

  def root
    File.expand_path('..', __dir__)
  end
end
