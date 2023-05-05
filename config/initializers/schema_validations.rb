require 'schema_validations'
SchemaValidations.setup do |config|
  config.auto_create = false #TODO Better to define validations explicitly
end