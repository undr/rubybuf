module Rubybuf
  class WithDefaultValues < Rubybuf::Message::Base
    required :id, :int, 1
    required :gender, :enum, 2, :default => :neuter, :values => [:female, :male, :neuter]
    optional :name, :string, 3, :default => "Unnamed"
    repeated :statuses, :enum, 4, :values => [:holy, :damned, :lowest, :highest, :aggressive, :positive, :sufferer], :default => [:holy, :highest, :positive]
  end
end