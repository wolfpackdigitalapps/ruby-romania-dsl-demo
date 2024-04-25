require_relative 'core'
require_relative 'validations'
require_relative 'associations'

class LessActiveRecord
  include Core
  include Validations
  include Associations
end
