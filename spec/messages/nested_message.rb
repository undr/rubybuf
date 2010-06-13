module Rubybuf
  class NestedMessage < Rubybuf::Message::Base
    required :id, :int, 1
    repeated :child, :message, 2, :class => Rubybuf::AllRules
  end
end