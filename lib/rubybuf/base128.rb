module Rubybuf
  module Base128
    module_function
    def base128_encode(value)
      raise ::ArgumentError, "value must by type of Integer" unless value.is_a?(Integer)
      raise ::RangeError, "#{value} is negative" if value < 0
      return [value].pack('C') if value < 128
      bytes = []
      until value == 0
        bytes << (0x80 | (value & 0x7f))
        value >>= 7
      end
      bytes[-1] &= 0x7f
      bytes.pack('C*')
    end
    
    def base128_encode_to(stream, value)
      stream.write(base128_encode(value))
    end
    
    def base128_decode(str)
      bytes = str.unpack('C*')
      value = 0
      bytes.each_with_index do |byte, index|
        byte &= ~(1 << 7) if byte >= 128
        value |= byte << (7 * index)
      end
      value
    end
    
    def base128_decode_from(stream)
      value = 0
      index = 0
      continue = true
      while continue do
        byte = stream.readchar
        continue = false unless byte >= 128
        byte &= ~(1 << 7) if byte >= 128 
        value |= byte << (7 * index)
        index += 1
      end
      value
    end
    public :base128_decode_from, :base128_decode, :base128_encode_to, :base128_encode
  end
end