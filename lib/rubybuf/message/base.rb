module Rubybuf
  module Message
    class Base
      include Rubybuf::Base128
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
          raise ::StandardError, %!Field name #{name} has already been used in "#{self.name}".! if field_exists?(name)
          raise ::StandardError, %!Field number #{tag} has already been used in "#{self.name}" by field "#{name}".!  if field_tags.value?(tag)

          fields[name] = Rubybuf::Message::Field.build(rule, type, name, tag, options)
          field_tags[name] = tag
          
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
          @field_tags ||= {}
        end
      end
      
      def initialize(values = {})
        clear!
        values.each do |name, value|
          set_value(name, value)
        end
        if block_given?
          yield self
        end
      end
      
      def field_exists?(name)
        self.class.field_exists?(name)
      end
      
      def clear!
        @values = {}
        set_default_values
      end
      
      def write_to(writer)
        fields.each do |name, field|
          write_field_to(writer, field)
        end
        writer.rewind
      end
      
      def read_from(reader)
        while(true) do
          read_field_from(reader)
        end
      rescue EOFError
        reader.rewind
      end

      protected
      def set_default_values
        fields.each do |field_name, field|
          value = if field.rule == :required || field.rule == :optional
            field.options[:default] ? field.options[:default] : nil
          elsif field.rule == :repeated
            field.options[:default] ? field.options[:default] : []
          end
          set_value(field_name, value)
        end
      end
      
      def fields
        self.class.fields
      end
      
      def field(name)
        return self.class.fields[name] if field_exists?(name)
        nil
      end
      def field_tags
        self.class.field_tags
      end
      def write_field_to(writer, field)
        value = @values[field.name]
        return if field.rule == :optional && value_is_empty_or_nul?(value)
        if field.rule == :repeated
          value.each do |item|
            write_header_to(writer, field)
            field.write_to(writer, item)
          end
        else
          write_header_to(writer, field)
          field.write_to(writer, value)
        end
      end
      
      def value_is_empty_or_nul?(value)
        return true if value.nil?
        value.empty? if value.respond_to?(:empty?)
      end
      
      def read_field_from(reader)
        field = read_header_from(reader)
        if field.rule == :repeated
          get_value(field.name) << field.read_from(reader)
        else
          set_value(field.name, field.read_from(reader))
        end
      end
      
      def get_value(name)
        return @values[name] if @values[name]
        nil
      end
  
      def set_value(name, value)
        @values[name] = value if field_exists?(name) && field(name).valid_value_type?(value)
      end
      
      def write_header_to(writer, field)
        header = field_tags[field.name] << 3
        header |= field.wire_type
        base128_encode_to(writer, header)
      end
      
      def read_header_from(reader)
        header = base128_decode_from(reader)
        tag = header >> 3
        wite_type = header & 0x07
        name = field_tags.index(tag)
        raise ::StandardError, "class #{self.class.name} field tag #{tag} not found. Name: #{name}" unless field_exists?(name)
        field = field(name)
        raise ::StandardError, "class #{self.class.name}. Discrepancy of wire types. Name: #{name}, Source: #{wite_type}, Exist: #{field.wire_type}" unless field.wire_type == wite_type
        field
      end
    end
  end
end
