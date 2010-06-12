require "spec_helper"

describe Rubybuf::Message::Field::Uint do
  before(:each) do
    @field = Rubybuf::Message::Field::Uint.new(:required, :price, 1, {})
  end
  context ".valid_value_type?" do
    it "returns true if value is valid" do
      [12, 120].each do |value|
        @field.valid_value_type?(value).should == true
      end
    end
    it "returns false if value isn't valid" do
      [-12, 12.3, "string", Object.new, :symbol].each do |value|
        @field.valid_value_type?(value).should == false
      end
    end
  end
  context ".write_to" do
    it "writes value to writer" do
      writer = StringIO.new
      @field.write_to(writer, 12)
      writer.pos = 0
      writer.read.should == "\f"
      writer = StringIO.new
      @field.write_to(writer, 150)
      writer.pos = 0
      writer.read.should == "\226\001"
    end
  end
  context ".read_from" do
    it "reads value from reader" do
      reader = StringIO.new("\f")
      @field.read_from(reader).should == 12
      reader = StringIO.new("\226\001")
      @field.read_from(reader).should == 150
    end
  end
end