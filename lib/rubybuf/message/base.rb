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
          if fields.keys.include?(name)
            raise ::StandardError, %!{Field name #{name} has already been used in "#{self.name}".!
          end
          if field_tags.include?(tag)
            raise ::StandardError, %!{Field number #{tag} has already been used in "#{self.name}" by field "#{name}".!
          end
          fields[name] = Rubybuf::Message::Field.build(rule, type, name, tag, options)
          field_tags << tag
        end
        
        def fields
          @fields ||= {}
        end
        def field_tags
          @field_tags ||= []
        end
        def clear_fields
          @fields = {}
          @field_tags = []
        end
      end
    end
  end
end