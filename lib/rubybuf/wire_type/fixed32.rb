module Rubybuf
  module WireType
    module Fixed32
      module_function
      def write_wiretype_data(writer, value)
        writer.write([value].pack('V'))
      end
      
      def read_wiretype_data(reader)
        reader.read(4).unpack("V")[0]
      end
      
      def wire_type
        Rubybuf::Message::Field::WIRETYPE_FIXED32
      end
      public :wire_type, :read_wiretype_data, :write_wiretype_data
    end
  end
end