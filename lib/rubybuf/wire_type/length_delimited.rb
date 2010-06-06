module Rubybuf
  module WireType
    class LengthDelimited
      class << self
        def write(stream, value)
          Rubybuf::Base128.base128_encode_to(stream, value.length)
          stream.write(value)
        end
        def read(stream)
          length = Rubybuf::Base128.base128_decode_from(stream)
          stream.read(length)
        end
      end
    end
  end
end