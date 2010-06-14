require "spec_helper"

describe Rubybuf::Message::Field::Bool do
  before(:each) do
    @field = Rubybuf::Message::Field::Bool.new(:required, :is_admin, 1, {})
  end
  it "contains method #wire_type which returns Rubybuf::Message::Field::WIRETYPE_VARINT" do
    @field.should respond_to(:wire_type)
    @field.wire_type.should == Rubybuf::Message::Field::WIRETYPE_VARINT
  end
  context ".valid_value_type?" do
    it "returns true if value is valid" do
      [true, false].each do |value|
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
      @field.write_to(writer, true)
      writer.pos = 0
      writer.read.should == "\001"
      writer = StringIO.new
      @field.write_to(writer, false)
      writer.pos = 0
      writer.read.should == "\000"
    end
  end
  context ".read_from" do
    it "reads value from reader" do
      reader = StringIO.new("\001")
      @field.read_from(reader).should === true
      reader = StringIO.new("\000")
      @field.read_from(reader).should === false
    end
  end
end