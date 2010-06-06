module Rubybuf
  module Message
    class Field
      def self.build(rule, type, name, tag, options = {})
        self.new(rule, name, tag, options)
      end
      
      def initialize(rule, name, tag, options)
        
      end
    end
  end
end