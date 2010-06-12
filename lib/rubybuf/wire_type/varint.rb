module Rubybuf
  module WireType
    module Varint
      module_function
      def write_wiretype_data(writer, value)
        Rubybuf::Base128.base128_encode_to(writer, value)
      end
      
      def read_wiretype_data(reader)
        Rubybuf::Base128.base128_decode_from(reader)
      end
      
      def wire_type
        Rubybuf::Message::Field::WIRETYPE_VARINT
      end
      public :wire_type, :read_wiretype_data, :write_wiretype_data
    end
  end
end