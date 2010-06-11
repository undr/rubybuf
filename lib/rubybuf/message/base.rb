module Rubybuf
  module Message
    class Base
      class << self
        def required(name, type, tag, options = {})
          define_field(:required, type, name, tag, options)
        end
        
        def optional(name, type, tag, options = {})
          define_field(:optional, type, name, tag, options)
        end
        
        def repeated(name, type, tag, options = {})
          define_field(:repeated, type, name, tag, options)
        end
        
        def define_field(rule, type, name, tag, options)
          if field_exists?(name)
            raise ::StandardError, %!Field name #{name} has already been used in "#{self.name}".!
          end
          if field_tags.include?(tag)
            raise ::StandardError, %!Field number #{tag} has already been used in "#{self.name}" by field "#{name}".!
          end
          fields[name] = Rubybuf::Message::Field.build(rule, type, name, tag, options)
          field_tags << tag
          define_method(name) do
            get_value(name)
          end
          define_method("#{name}=") do | value |
            set_value(name, value)
          end
        end
        
        def field_exists?(name)
          fields.keys.include?(name)
        end
        
        def fields
          @fields ||= {}
        end
        
        def field_tags
          @field_tags ||= []
        end
      end
      
      def initialize(values = {})
        values.each do |name, value|
          set_value(name, value)
        end
      end
      
      def get_value(name)
        return @fields[name].value if self.class.field_exists?(name)
        nil
      end
      
      def set_value(name, value)
        @fields[name].value = value if self.class.field_exists?(name)
      end
    end
  end
end