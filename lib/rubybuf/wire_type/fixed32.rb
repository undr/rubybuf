module Rubybuf
  module WireType
    module Fixed32
      def write_wiretype_data(writer, value)
        writer.write([value].pack('V'))
      end
      
      def read_wiretype_data(reader)
        reader.read(4).unpack("V")[0]
      end
      
      def wire_type
        Rubybuf::Message::Field::WIRETYPE_FIXED32
      end
    end
  end
end