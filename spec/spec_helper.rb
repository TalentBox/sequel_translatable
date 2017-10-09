require "i18n"
require "sequel"
I18n.enforce_available_locales = false
DB = Sequel.sqlite
