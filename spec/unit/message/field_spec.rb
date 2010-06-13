require "spec_helper"

describe Rubybuf::Message::Field do
  it "contains array with field type names" do
    Rubybuf::Message::Field::TYPES.should be_a(Array)
    Rubybuf::Message::Field::TYPES.should include(:int, :sint, :string, :uint, :bool, :enum, :bytes, :message)
  end
  context ".build" do
    Rubybuf::Message::Field::TYPES.each do |type|
      it "returns class instance of Rubybuf::Message::Field::#{type.to_s.capitalize} type when pass '#{type}' as second argument" do
        Rubybuf::Message::Field.build(:required, type, :field, 1).should be_a(Rubybuf::Message::Field.const_get("#{type.to_s.capitalize}"))
      end
    end
  end
  describe Rubybuf::Message::Field::Base do
    context ".initialize" do
      it "set @rule and @name public vars" do
        field = Rubybuf::Message::Field::Base.new(:required, :name, 1, {:values => [:one, :two]})
        field.rule.should be(:required)
        field.name.should be(:name)
        field.options.should == {:values => [:one, :two]}
      end
    end
  end
end