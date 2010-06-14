require "spec_helper"

describe Rubybuf::Message::Field::Double do
  before(:each) do
    @field = Rubybuf::Message::Field::Double.new(:required, :balance, 1, {})
  end
  it "contains method #wire_type which returns Rubybuf::Message::Field::WIRETYPE_FIXED32" do
    @field.should respond_to(:wire_type)
    @field.wire_type.should == Rubybuf::Message::Field::WIRETYPE_FIXED64
  end
  context ".valid_value_type?" do
    it "returns true if value is valid" do
      [12, 15.10, -123456.123, 0].each do |value|
        @field.valid_value_type?(value).should == true
      end
    end
    it "returns false if value isn't valid" do
      ["string", Object.new, :symbol].each do |value|
        @field.valid_value_type?(value).should == false
      end
    end
  end
  context ".write_to" do
    it "writes value to writer" do
      writer = StringIO.new
      @field.write_to(writer, 12)
      writer.rewind
      writer.read.should == "\000\000\000\000\000\000(@"
      writer = StringIO.new
      @field.write_to(writer, -12)
      writer.rewind
      writer.read.should == "\000\000\000\000\000\000(\300"
      writer = StringIO.new
      @field.write_to(writer, 1234567890123.12)
      writer.rewind
      writer.read.should == "\354\261L\260\037\367qB"
      writer = StringIO.new
      @field.write_to(writer, -1234567890123.12)
      writer.rewind
      writer.read.should == "\354\261L\260\037\367q\302"
    end
  end
  context ".read_from" do
    it "reads value from reader" do
      reader = StringIO.new("\000\000\000\000\000\000(@")
      @field.read_from(reader).should == 12
      reader = StringIO.new("\000\000\000\000\000\000(\300")
      @field.read_from(reader).should == -12
      reader = StringIO.new("\354\261L\260\037\367qB")
      @field.read_from(reader).should == 1234567890123.12
      reader = StringIO.new("\354\261L\260\037\367q\302")
      @field.read_from(reader).should == -1234567890123.12
    end
  end
end