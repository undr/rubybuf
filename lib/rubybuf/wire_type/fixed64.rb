module Rubybuf
  module WireType
    module Fixed64
      module_function
      def write_wiretype_data(writer, value)
        writer.write([value & 0xffff_ffff, value >> 32].pack('VV'))
      end
      
      def read_wiretype_data(reader)
        value = reader.read(8).unpack("VV")
        value[0] + (value[1] << 32)
      end
      
      def wire_type
        Rubybuf::Message::Field::WIRETYPE_FIXED64
      end
      public :wire_type, :read_wiretype_data, :write_wiretype_data
    end
  end
end