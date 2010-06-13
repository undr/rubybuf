module Rubybuf
  class AllTypes < Rubybuf::Message::Base
    required :id, :int, 1
    required :balance, :sint, 2
    required :price, :uint, 3
    required :is_admin, :bool, 4
    required :status, :enum, 5, :values => [:active, :inactive, :deleted]
    required :name, :string, 6
  end
end