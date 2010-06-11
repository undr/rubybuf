require "spec_helper"
module Rubybuf
  module WireType
    module Varint
      include Rubybuf::Base128
    end
  end
end
describe Rubybuf::WireType::Varint do
  describe ".read" do
    context "when read value from reader" do
      it "calls method Rubybuf::Base128#base128_encode_from" do
        stream = StringIO.new("\254\002")
        Rubybuf::WireType::Varint.expects(:base128_decode_from).with(stream).returns(300)
        Rubybuf::WireType::Varint.read_wiretype_data(stream).should == 300
      end
    end    
  end
  
  describe ".write" do
    context "when write value to writer" do
      it "calls method Rubybuf::Base128#base128_encode_to" do
        stream = StringIO.new
        Rubybuf::WireType::Varint.expects(:base128_encode_to).with(stream, 300).returns(2)
        Rubybuf::WireType::Varint.write_wiretype_data(stream, 300).should == 2
      end
    end    

  end
end