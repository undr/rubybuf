module Rubybuf
  module WireType
    module LengthDelimited
      module_function
      def write_wiretype_data(writer, value)
        Rubybuf::Base128.base128_encode_to(writer, value.length)
        writer.write(value)
      end
      
      def read_wiretype_data(reader)
        length = Rubybuf::Base128.base128_decode_from(reader)
        reader.read(length)
      end
      
      def wire_type
        Rubybuf::Message::Field::WIRETYPE_LENGTH_DELIMITED
      end
      public :wire_type, :read_wiretype_data, :write_wiretype_data
    end
  end
end