require "spec_helper"

describe Rubybuf::Message::Field::Sfixed64 do
  before(:each) do
    @field = Rubybuf::Message::Field::Sfixed64.new(:required, :balance, 1, {})
  end
  it "contains method #wire_type which returns Rubybuf::Message::Field::WIRETYPE_FIXED64" do
    @field.should respond_to(:wire_type)
    @field.wire_type.should == Rubybuf::Message::Field::WIRETYPE_FIXED64
  end
  context ".valid_value_type?" do
    it "returns true if value is valid" do
      [-12, 12, Rubybuf::Message::Field::INT64_MAX, Rubybuf::Message::Field::INT64_MIN, 0].each do |value|
        @field.valid_value_type?(value).should == true
      end
    end
    it "returns false if value isn't valid" do
      [12.3, "string", Object.new, :symbol, Rubybuf::Message::Field::INT64_MIN - 1, Rubybuf::Message::Field::INT64_MAX + 1].each do |value|
        @field.valid_value_type?(value).should == false
      end
    end
  end
  context ".write_to" do
    it "writes value to writer" do
      writer = StringIO.new
      @field.write_to(writer, 12)
      writer.rewind
      writer.read.should == "\f\000\000\000\000\000\000\000"
      writer = StringIO.new
      @field.write_to(writer, -12)
      writer.rewind
      writer.read.should == "\364\377\377\377\377\377\377\377"
      writer = StringIO.new
      @field.write_to(writer, Rubybuf::Message::Field::INT64_MAX)
      writer.rewind
      writer.read.should == "\377\377\377\377\377\377\377\177"
      writer = StringIO.new
      @field.write_to(writer, Rubybuf::Message::Field::INT64_MIN)
      writer.rewind
      writer.read.should == "\000\000\000\000\000\000\000\200"
    end
  end
  context ".read_from" do
    it "reads value from reader" do
      reader = StringIO.new("\f\000\000\000\000\000\000\000")
      @field.read_from(reader).should == 12
      reader = StringIO.new("\364\377\377\377\377\377\377\377")
      @field.read_from(reader).should == -12
      reader = StringIO.new("\377\377\377\377\377\377\377\177")
      @field.read_from(reader).should == Rubybuf::Message::Field::INT64_MAX
      reader = StringIO.new("\000\000\000\000\000\000\000\200")
      @field.read_from(reader).should == Rubybuf::Message::Field::INT64_MIN
    end
  end
end