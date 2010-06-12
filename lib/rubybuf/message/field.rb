module Rubybuf
  module Message
    module Field
      TYPES = [:int, :sint, :string, :uint, :bool, :enum, :bytes].freeze
      
      WIRETYPE_VARINT = 0;
      WIRETYPE_FIXED64 = 1;
      WIRETYPE_LENGTH_DELIMITED = 2;
      WIRETYPE_START_GROUP = 3;
      WIRETYPE_END_GROUP = 4;
      WIRETYPE_FIXED32 = 5;
      
      def self.build(rule, type, name, tag, options = {})
        raise StandardError, 'Unknown field type' unless TYPES.include?(type)
        klass = const_get("#{type.to_s.capitalize}")
        klass.new(rule, name, tag, options)
      end
      
      class Base
        attr_reader :rule, :name 
        include Rubybuf::Base128
        include Rubybuf::ZigZag
        def initialize(rule, name, tag, options)
          @rule = rule
          @name = name
          @tag = tag
          @options = options
        end
        
        def value=(value)
          raise ArgumentError, "value type is not valid" unless valid_value_type?(value)
          @value = value
        end
        
        def value
          default = nil
          default = [] if rule == :repeated
          @value ||= default
        end

        def valid_value_type?(value)
          if @rule == :repeated
            return false unless value.is_a?(Array)
            value.each do |item|
              return false unless valid_value_type_impl?(item)
            end
            return true
          end
          valid_value_type_impl?(value)
        end
        
        def read(reader)
          if @rule == :repeated
            self.value << read_impl(reader)
          else
            self.value = read_impl(reader)
          end
        end
        
        def write(writer)
          return if @rule == :optional && value_is_empty_or_nul?
          if @rule == :repeated
            self.value.each do |item|
              #p item.inspect
              write_header(writer)
              write_impl(writer, item)
            end
          else
            write_header(writer)
            write_impl(writer, self.value)
          end
        end
        
        protected
        def value_is_empty_or_nul?
          return true if self.value.nil?
          self.value.empty? if self.value.respond_to?(:empty?)
        end
        
        def valid_value_type_impl?(value)
          raise NotImplementedError
        end
        
        def write_impl(writer, value)
          raise NotImplementedError
        end
        
        def read_impl(reader)
          raise NotImplementedError
        end
        
        def write_header(writer)
          header = @tag << 3
          header |= wire_type
          base128_encode_to(writer, header)
        end
      end

      class Int < Base
        include Rubybuf::WireType::Varint
        protected
        def valid_value_type_impl?(value)
          value.is_a?(::Integer)
        end
        
        def write_impl(writer, value)
          write_wiretype_data(writer, value)
        end
        
        def read_impl(reader)
          read_wiretype_data(reader).to_i
        end
      end

      class Sint < Base
        include Rubybuf::WireType::Varint
        protected
        def valid_value_type_impl?(value)
          value.is_a?(::Integer)
        end
        
        def write_impl(writer, value)
          write_wiretype_data(writer, zigzag_encode(value))
        end
        
        def read_impl(reader)
          zigzag_decode(read_wiretype_data(reader).to_i)
        end
      end

      class String < Base
        include Rubybuf::WireType::LengthDelimited
        protected
        def valid_value_type_impl?(value)
          value.is_a?(::String)
        end
        
        def write_impl(writer, value)
          write_wiretype_data(writer, value.to_i)
        end
        
        def read_impl(reader)
          read_wiretype_data(reader).to_s
        end
      end

      class Uint < Base
        include Rubybuf::WireType::Varint
        protected
        def valid_value_type_impl?(value)
          value.is_a?(::Integer) && value >= 0
        end
        
        def write_impl(writer, value)
          write_wiretype_data(writer, value)
        end
        
        def read_impl(reader)
          read_wiretype_data(reader).to_i
        end
      end

      class Bool < Base
        include Rubybuf::WireType::Varint
        protected
        def valid_value_type_impl?(value)
          true
        end
        
        def write_impl(writer, value)
          write_wiretype_data(writer, value.to_i)
        end
        
        def read_impl(reader)
          !!read_wiretype_data(reader)
        end
      end

      class Enum < Base
        include Rubybuf::WireType::Varint
        protected
        def valid_value_type_impl?(value)
          @options[:values].include?(value)
        end
        
        def write_impl(writer, value)
          index = @options[:values].index(value)
          raise ::StandardError if index.nil?
          write_wiretype_data(writer, index) 
        end
        
        def read_impl(reader)
          index = read_wiretype_data(reader)
          raise ::StandardError unless @options[:values][index]
          @options[:values][index]
        end
      end

      class Bytes < Base
        include Rubybuf::WireType::LengthDelimited
        protected
        def valid_value_type_impl?(value)
          true
        end
        
        def write_impl(writer, value)
          write_wiretype_data(writer, value)
        end
        
        def read_impl(reader)
          read_wiretype_data(reader).to_s
        end
      end
    end
  end
end