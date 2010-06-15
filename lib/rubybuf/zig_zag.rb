module Rubybuf
  module ZigZag
    def zigzag_encode(value)
      raise ::ArgumentError, "value must by type of Integer" unless value.is_a?(Integer)
      if value >= 0
        value * 2
      else
        (value * 2).abs - 1
      end
    end
    
    def zigzag_decode(value)
      raise ::ArgumentError, "value must by type of Integer" unless value.is_a?(Integer)
      raise ::RangeError, "#{value} is negative" if value < 0
      result = value / 2
      result = -(result + 1) if value.modulo(2) == 1
      result
    end
  end
end