module Validations
  class ValidationError < StandardError; end

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def validates(*attributes)
      attributes.each do |attribute|
        define_method "validate_#{attribute}" do
          value = instance_variable_get("@#{attribute}")
          raise ValidationError, "#{attribute} can't be blank" if value.nil? || value.to_s.strip.empty?
        end
      end
    end
  end
end
