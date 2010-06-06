require "spec_helper"

describe Rubybuf::WireType::LengthDelimited do
  before :all do
    @stream = mock()
  end
  
  describe ".read" do
    context "when read value from reader" do
      it "calls method Rubybuf::Base128#base128_decode_from" do
        Rubybuf::Base128.expects(:base128_decode_from).with(@stream).returns(7)
        @stream.expects(:read).with(7).returns("it work")
        Rubybuf::WireType::LengthDelimited.read(@stream).should == "it work"
      end
    end    
  end
  
  describe ".write" do
    context "when write value to writer" do
      it "calls method Rubybuf::Base128#base128_encode_to" do
        Rubybuf::Base128.expects(:base128_encode_to).with(@stream, 7).returns(1)
        @stream.expects(:write).with("it work").returns(7)
        Rubybuf::WireType::LengthDelimited.write(@stream, "it work").should == 7
      end
    end    
  end
end