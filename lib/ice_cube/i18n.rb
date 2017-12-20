require 'ice_cube/null_i18n'

module IceCube
  module I18n

    LOCALES_PATH = File.expand_path(File.join('..', '..', '..', 'locales'), __FILE__)

    def self.t(*args)
      backend.t(*args)
    end

    def self.l(*args)
      backend.l(*args)
    end

    def self.backend
      @backend ||= detect_backend!
    end

    def self.detect_backend!
      ::I18n.load_path += Dir[File.join(LOCALES_PATH, 'ice_cube', '*.yml')]
      ::I18n
    rescue NameError
      NullI18n
    end
  end
end
