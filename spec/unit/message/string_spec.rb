require "spec_helper"

describe Rubybuf::Message::Field::String do
  before(:each) do
    @field = Rubybuf::Message::Field::String.new(:required, :balance, 1, {})
    @long_string = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent sagittis tincidunt nibh et mattis. Mauris commodo semper elit, in viverra mauris dictum et. Nam dignissim euismod cursus. Sed non justo a urna adipiscing posuere id vel massa. Duis tincidunt magna vitae augue hendrerit facilisis. Sed vehicula mauris vitae justo blandit auctor. Nulla sit amet cursus libero. Morbi massa nulla, ornare in ultrices et, posuere sit amet magna. Aenean augue eros, tempus sed suscipit id, luctus eget urna. Pellentesque et lorem ornare urna aliquam auctor. Suspendisse non tincidunt elit. Nunc quis odio tincidunt augue sagittis ullamcorper ut imperdiet turpis. In non turpis in quam consequat volutpat vitae sed libero. Aliquam dapibus sollicitudin fermentum. Aliquam cursus posuere mauris tincidunt condimentum. Aenean pharetra ultricies tempus."
    @long_string_length = @long_string.length
  end
  context ".valid_value_type?" do
    it "returns true if value is valid string" do
      @field.valid_value_type?("string").should == true
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
      @field.write_to(writer, "Valid string")
      writer.pos = 0
      writer.read.should == "\fValid string"
      writer.pos = 0
      Rubybuf::Base128.base128_decode_from(writer).should == 12
      writer = StringIO.new
      @field.write_to(writer, @long_string)
      writer.pos = 0
      writer.read.should == "\311\006#{@long_string}"
      writer.pos = 0
      Rubybuf::Base128.base128_decode_from(writer).should == @long_string_length
    end
  end
  context ".read_from" do
    it "reads value from reader" do
      reader = StringIO.new("\fValid string")
      @field.read_from(reader).should == "Valid string"
      reader = StringIO.new("\fValid stringAndAnotherAdditionalString")
      @field.read_from(reader).should == "Valid string"
      reader = StringIO.new("\311\006#{@long_string}")
      @field.read_from(reader).should == @long_string
      reader = StringIO.new("\311\006#{@long_string}#{@long_string}")
      @field.read_from(reader).should == @long_string
    end
  end
end