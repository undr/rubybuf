module Rubybuf
  module Message
    module Field
      TYPES = [:int, :sint, :string, :uint, :fixed32, :sfixed32, :fixed64, :sfixed64, :bool, :enum, :bytes, :message].freeze
      
      WIRETYPE_VARINT = 0;
      WIRETYPE_FIXED64 = 1;
      WIRETYPE_LENGTH_DELIMITED = 2;
      WIRETYPE_START_GROUP = 3;
      WIRETYPE_END_GROUP = 4;
      WIRETYPE_FIXED32 = 5;
      
      INT32_MAX = 2**31 - 1
      INT32_MIN = -2**31
      INT64_MAX = 2**63 - 1
      INT64_MIN = -2**63
      UINT32_MAX = 2**32 - 1
      UINT64_MAX = 2**64 - 1
      
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
      
      class Fixed32 < Base
 
        def write_to(writer, value)
          writer.write([value].pack('V'))
        end
        
        def read_from(reader)
          reader.read(4).unpack("V")[0]
        end
        
        protected
        def valid_value_type_impl?(value)
          value.is_a?(::Integer) && value >= 0 && value <= ::Rubybuf::Message::Field::UINT32_MAX
        end
      end

      class Sfixed32 < Base
 
        def write_to(writer, value)
          writer.write([value].pack('V'))
        end
        
        def read_from(reader)
          value = reader.read(4).unpack("V")[0]
          value -= 0x1_0000_0000 if (value & 0x8000_0000).nonzero?
          value
        end
        
        protected
        def valid_value_type_impl?(value)
          value.is_a?(::Integer) && value >= ::Rubybuf::Message::Field::INT32_MIN && value <= ::Rubybuf::Message::Field::INT32_MAX
        end
      end
      
      class Fixed64 < Base
 
        def write_to(writer, value)
          writer.write([value & 0xffff_ffff, value >> 32].pack('VV'))
        end
        
        def read_from(reader)
          value = reader.read(8).unpack("VV")
          value[0] + (value[1] << 32)
        end
        
        protected
        def valid_value_type_impl?(value)
          value.is_a?(::Integer) && value >= 0 && value <= ::Rubybuf::Message::Field::UINT64_MAX
        end
      end

      class Sfixed64 < Base
 
        def write_to(writer, value)
          writer.write([value & 0xffff_ffff, value >> 32].pack('VV'))
        end
        
        def read_from(reader)
          value = reader.read(8).unpack("VV")
          value = value[0] + (value[1] << 32)
          value -= 0x1_0000_0000_0000_0000 if (value & 0x8000_0000_0000_0000).nonzero?
          value
        end
        
        protected
        def valid_value_type_impl?(value)
          value.is_a?(::Integer) && value >= ::Rubybuf::Message::Field::INT64_MIN && value <= ::Rubybuf::Message::Field::INT64_MAX
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
      
      class Bytes < Base
        include Rubybuf::WireType::LengthDelimited
        
        def write_to(writer, value)
          value.rewind
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
      class Message < Base
        include Rubybuf::WireType::LengthDelimited
        
        def write_to(writer, value)
          data = StringIO.new
          value.write_to(data)
          write_wiretype_data(writer, data.read)
        end
        
        def read_from(reader)
         data = StringIO.new(read_wiretype_data(reader).to_s)
         message = @options[:class].new
         message.read_from(data)
         message
        end
        
        protected
        def valid_value_type_impl?(value)
          value.is_a?(::Rubybuf::Message::Base)
        end
      end
    end
  end
end