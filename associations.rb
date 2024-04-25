module Associations
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def belongs_to(association_name, options = {})
      define_method(association_name) do
        association_class = options[:class_name] || association_name.to_s
        foreign_key = options[:foreign_key] || "#{association_name}_id"

        Object.const_get(association_class.capitalize).find(instance_variable_get("@#{foreign_key}"))
      end
    end
  end
end
