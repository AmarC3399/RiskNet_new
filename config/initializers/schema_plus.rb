require 'schema_plus'
SchemaPlus.setup do |config|
  config.foreign_keys.auto_create = false
end
