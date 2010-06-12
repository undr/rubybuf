require "spec_helper"

describe Rubybuf::Message::Field do
  it "contains array with field type names" do
    Rubybuf::Message::Field::TYPES.should be_a(Array)
    Rubybuf::Message::Field::TYPES.should include(:int, :sint, :string, :uint, :bool, :enum, :bytes)
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
        field = Rubybuf::Message::Field::Base.new(:required, :name, 1, {})
        field.rule.should be(:required)
        field.name.should be(:name)
      end
    end
  end
  describe Rubybuf::Message::Field::Int do
    before(:each) do
      @field = Rubybuf::Message::Field::Int.new(:required, :name, 1, {})
    end
    it "gets and sets valid value" do
      @field.value = 12
      @field.value.should == 12
      @field.value = -12
      @field.value.should == -12
    end
    it "raise error when sets invalid value" do
      lambda{@field.value = "string"}.should raise_error(::ArgumentError)
      lambda{@field.value = 12.4}.should raise_error(::ArgumentError)
      lambda{@field.value = Object.new}.should raise_error(::ArgumentError)
    end
  end
  describe Rubybuf::Message::Field::String do
    before(:each) do
      @field = Rubybuf::Message::Field::String.new(:required, :name, 1, {})
    end
    it "gets and sets valid value" do
      @field.value = "string"
      @field.value.should == "string"
    end
    it "raise error when sets invalid value" do
      lambda{@field.value = 12}.should raise_error(::ArgumentError)
      lambda{@field.value = 12.4}.should raise_error(::ArgumentError)
      lambda{@field.value = Object.new}.should raise_error(::ArgumentError)
    end
  end
  describe Rubybuf::Message::Field::Uint do
    before(:each) do
      @field = Rubybuf::Message::Field::Uint.new(:required, :name, 1, {})
    end
    it "gets and sets valid value" do
      @field.value = 12
      @field.value.should == 12
    end
    it "raise error when sets invalid value" do
      lambda{@field.value = "string"}.should raise_error(::ArgumentError)
      lambda{@field.value = -12}.should raise_error(::ArgumentError)
      lambda{@field.value = 12.4}.should raise_error(::ArgumentError)
      lambda{@field.value = Object.new}.should raise_error(::ArgumentError)
    end
  end
  describe Rubybuf::Message::Field::Enum do
    before(:each) do
      @values = [:one, :two, :three, :and_more]
      @field = Rubybuf::Message::Field::Enum.new(:required, :name, 1, {:values => @values})
    end
    it "gets and sets valid value" do
      @values.each do |v|
        @field.value = v
        @field.value.should == v
      end
    end
    it "raise error when sets invalid value" do
      [:four, :five, :six, :etc].each do |v|
        lambda{@field.value = v}.should raise_error(::ArgumentError)
      end
    end
  end
  describe "Any field class with 'repeated' rule" do
    context "when I set value" do
      before(:each) do
        @field = Rubybuf::Message::Field::Int.new(:repeated, :name, 1, {})
      end
      it "should be convinced that value type of Array" do
        lambda{@field.value = 12}.should raise_error(::ArgumentError)
        lambda{@field.value = "string"}.should raise_error(::ArgumentError)
        lambda{@field.value = 12.3}.should raise_error(::ArgumentError)
        lambda{@field.value = -12}.should raise_error(::ArgumentError)
        
        lambda{@field.value = [1, 2, 3, 4]}.should_not raise_error(::ArgumentError)
      end
      it "should check that each element of array is valid" do
        lambda{@field.value = ["string1", "string2", "string3"]}.should raise_error(::ArgumentError)
        lambda{@field.value = [12, -12, "string3"]}.should raise_error(::ArgumentError)
        
        lambda{@field.value = [12, -12, 21]}.should_not raise_error(::ArgumentError)
      end
    end
  end
end