module Rubybuf
  class AllRules < Rubybuf::Message::Base
    required :id, :int, 1
    optional :name, :string, 2, :default => "Unnamed"
    repeated :statuses, :enum, 3, :values => [:holy, :damned, :lowest, :highest, :aggressive, :positive, :sufferer]
  end
end