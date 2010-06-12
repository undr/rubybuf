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
        attr_reader :rule, :name, :options
        include Rubybuf::Base128
        include Rubybuf::ZigZag
        def initialize(rule, name, tag, options)
          @rule = rule
          @name = name
          @tag = tag
          @options = options
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
        
        def read_from(reader)
          raise NotImplementedError
        end
        
        def write_to(writer)
          raise NotImplementedError
        end
        
        protected
        def valid_value_type_impl?(value)
          raise NotImplementedError
        end
      end

      class Int < Base
        include Rubybuf::WireType::Varint
      
        def write_to(writer, value)
          write_wiretype_data(writer, value)
        end
        
        def read_from(reader)
          read_wiretype_data(reader).to_i
        end
        protected
        def valid_value_type_impl?(value)
          value.is_a?(::Integer)
        end
      end

      class Sint < Base
        include Rubybuf::WireType::Varint

        def write_to(writer, value)
          write_wiretype_data(writer, zigzag_encode(value))
        end
        
        def read_from(reader)
          zigzag_decode(read_wiretype_data(reader).to_i)
        end
        
        protected
        def valid_value_type_impl?(value)
          value.is_a?(::Integer)
        end
      end

      class String < Base
        include Rubybuf::WireType::LengthDelimited

        def write_to(writer, value)
          write_wiretype_data(writer, value)
        end
        
        def read_from(reader)
          read_wiretype_data(reader).to_s
        end
        
        protected
        def valid_value_type_impl?(value)
          value.is_a?(::String)
        end
      end

      class Uint < Base
        include Rubybuf::WireType::Varint
        
        def write_to(writer, value)
          write_wiretype_data(writer, value)
        end
        
        def read_from(reader)
          read_wiretype_data(reader).to_i
        end
        
        protected
        def valid_value_type_impl?(value)
          value.is_a?(::Integer) && value >= 0
        end
      end

      class Bool < Base
        include Rubybuf::WireType::Varint
        
        def write_to(writer, value)
          write_wiretype_data(writer, bool_to_i(value))
        end
        
        def read_from(reader)
          i_to_bool(read_wiretype_data(reader))
        end
        
        protected
        def valid_value_type_impl?(value)
          value.is_a?(::FalseClass) || value.is_a?(::TrueClass)
        end
        
        def bool_to_i(value)
          if value.is_a?(::FalseClass)
            0
          else
            1
          end
        end
        
        def i_to_bool(value)
          if value == 0
            false
          else
            true
          end
        end
      end

      class Enum < Base
        include Rubybuf::WireType::Varint
        
        def write_to(writer, value)
          index = @options[:values].index(value)
          raise ::StandardError if index.nil?
          write_wiretype_data(writer, index) 
        end
        
        def read_from(reader)
          index = read_wiretype_data(reader)
          raise ::StandardError unless @options[:values][index]
          @options[:values][index]
        end
        
        protected
        def valid_value_type_impl?(value)
          @options[:values].include?(value)
        end
      end

      class Bytes < Base
        include Rubybuf::WireType::LengthDelimited
        
        def write_to(writer, value)
          value.pos = 0
          write_wiretype_data(writer, value.read)
        end
        
        def read_from(reader)
          StringIO.new(read_wiretype_data(reader).to_s)
        end
        
        protected
        def valid_value_type_impl?(value)
          value.is_a?(StringIO)
        end
      end
    end
  end
end