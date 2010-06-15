module Rubybuf
  module WireType
    module LengthDelimited
      def write_wiretype_data(writer, value)
        base128_encode_to(writer, value.length)
        writer.write(value)
      end
      
      def read_wiretype_data(reader)
        length = base128_decode_from(reader)
        reader.read(length)
      end
      
      def wire_type
        Rubybuf::Message::Field::WIRETYPE_LENGTH_DELIMITED
      end
    end
  end
end