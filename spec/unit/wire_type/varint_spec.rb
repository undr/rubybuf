require "spec_helper"

describe Rubybuf::WireType::Varint do
  describe ".read" do
    context "when read value from reader" do
      it "calls method Rubybuf::Base128#base128_encode_from" do
        stream = StringIO.new("\254\002")
        Rubybuf::Base128.expects(:base128_decode_from).with(stream).returns(300)
        Rubybuf::WireType::Varint.read(stream).should == 300
      end
    end    
  end
  
  describe ".write" do
    context "when write value to writer" do
      it "calls method Rubybuf::Base128#base128_encode_to" do
        stream = StringIO.new
        Rubybuf::Base128.expects(:base128_encode_to).with(stream, 300).returns(2)
        Rubybuf::WireType::Varint.write(stream, 300).should == 2
      end
    end    

  end
end