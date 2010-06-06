module Rubybuf
  class Example < Rubybuf::Message::Base
    required :id, :int, 1
    required :balance, :sint, 2
    required :is_admin, :bool, 3
    required :status, :enum, 4, :values => ['active', 'inactive', 'deleted']
    required :name, :string, 5
    required :bytes, :bytes, 6
  end
end