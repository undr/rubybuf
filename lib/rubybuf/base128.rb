module Rubybuf
  module Base128
    module_function
    def encode(value)
      raise ::ArgumentError, "value mast by type of Integer" unless value.is_a?(Integer)
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
   
    def decode(str)
      bytes = str.unpack('C*')
      value = 0
      bytes.each_with_index do |byte, index|
        byte &= ~(1 << 7) if byte > 128 
        value |= byte << (7 * index)
      end
      value

    end

  end
end