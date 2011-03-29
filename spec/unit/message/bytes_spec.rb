require "spec_helper"
require "pp"
describe Rubybuf::Message::Field::Bytes do
  before(:all) do
    @klass = Object.new
    @klass.extend(Rubybuf::Base128)
    #puts `pwd`
    @long_data = File.open("./spec/binary.file", "r").read #"Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent sagittis tincidunt nibh et mattis. Mauris commodo semper elit, in viverra mauris dictum et. Nam dignissim euismod cursus. Sed non justo a urna adipiscing posuere id vel massa. Duis tincidunt magna vitae augue hendrerit facilisis. Sed vehicula mauris vitae justo blandit auctor. Nulla sit amet cursus libero. Morbi massa nulla, ornare in ultrices et, posuere sit amet magna. Aenean augue eros, tempus sed suscipit id, luctus eget urna. Pellentesque et lorem ornare urna aliquam auctor. Suspendisse non tincidunt elit. Nunc quis odio tincidunt augue sagittis ullamcorper ut imperdiet turpis. In non turpis in quam consequat volutpat vitae sed libero. Aliquam dapibus sollicitudin fermentum. Aliquam cursus posuere mauris tincidunt condimentum. Aenean pharetra ultricies tempus."
    @long_data_length = @long_data.length
  end
  before(:each) do
    @field = Rubybuf::Message::Field::Bytes.new(:required, :bytes, 1, {})
    
  end
  it "contains method #wire_type which returns Rubybuf::Message::Field::WIRETYPE_LENGTH_DELIMITED" do
    @field.should respond_to(:wire_type)
    @field.wire_type.should == Rubybuf::Message::Field::WIRETYPE_LENGTH_DELIMITED
  end
  context ".valid_value_type?" do
    it "returns true if value is valid string" do
      ["string", "\000\000\043Slava KPSS!!!"].each do |value|
        @field.valid_value_type?(value).should == true
      end
    end
    it "returns false if value isn't valid" do
      [12.3, 12, -12, Object.new, :symbol].each do |value|
        @field.valid_value_type?(value).should == false
      end
    end
  end
  context ".write_to" do
    it "writes value to writer" do
      writer = StringIO.new
      @field.write_to(writer, "Valid bytes sequence")
      writer.pos = 0
      writer.read.should == "\024Valid bytes sequence"
      writer.pos = 0
      @klass.base128_decode_from(writer).should == 20
      writer = StringIO.new
      @field.write_to(writer, @long_data)
      writer.pos = 0
      writer.read.should == "\261P#{@long_data}"
      writer.pos = 0
      @klass.base128_decode_from(writer).should == @long_data_length
    end
  end
  context ".read_from" do
    it "reads value from reader" do
      reader = StringIO.new("\024Valid bytes sequence")
      @field.read_from(reader).should == "Valid bytes sequence"
      reader = StringIO.new("\024Valid bytes sequenceAndAnotherAdditionalSequence")
      @field.read_from(reader).should == "Valid bytes sequence"
      reader = StringIO.new("\261P#{@long_data}")
      @field.read_from(reader).should == @long_data
      reader = StringIO.new("\261P#{@long_data}#{@long_data}")
      @field.read_from(reader).should == @long_data
    end
  end
end