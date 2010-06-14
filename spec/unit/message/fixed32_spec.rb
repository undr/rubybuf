require "spec_helper"

describe Rubybuf::Message::Field::Fixed32 do
  before(:each) do
    @field = Rubybuf::Message::Field::Fixed32.new(:required, :balance, 1, {})
  end
  context ".valid_value_type?" do
    it "returns true if value is valid" do
      [12, 150, Rubybuf::Message::Field::UINT32_MAX, 0].each do |value|
        @field.valid_value_type?(value).should == true
      end
    end
    it "returns false if value isn't valid" do
      [12.3, "string", Object.new, :symbol, Rubybuf::Message::Field::UINT32_MAX + 1, -12].each do |value|
        @field.valid_value_type?(value).should == false
      end
    end
  end
  context ".write_to" do
    it "writes value to writer" do
      writer = StringIO.new
      @field.write_to(writer, 12)
      writer.rewind
      writer.read.should == "\f\000\000\000"
      writer = StringIO.new
      @field.write_to(writer, 150)
      writer.rewind
      writer.read.should == "\226\000\000\000"
      writer = StringIO.new
      @field.write_to(writer, Rubybuf::Message::Field::UINT32_MAX)
      writer.rewind
      writer.read.should == "\377\377\377\377"
    end
  end
  context ".read_from" do
    it "reads value from reader" do
      reader = StringIO.new("\f\000\000\000")
      @field.read_from(reader).should == 12
      reader = StringIO.new("\226\000\000\000")
      @field.read_from(reader).should == 150
      reader = StringIO.new("\377\377\377\377")
      @field.read_from(reader).should == Rubybuf::Message::Field::UINT32_MAX
    end
  end
end