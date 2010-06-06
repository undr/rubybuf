module Rubybuf
  module WireType
    class Varint
      class << self
        def write(stream, value)
          Rubybuf::Base128.base128_encode_to(stream, value)
        end
        def read(stream)
          Rubybuf::Base128.base128_decode_from(stream)
        end
      end
    end
  end
end