require "spec_helper"

describe Rubybuf::WireType::Varint do
  before :all do
    @klass = Object.new
    @klass.extend(Rubybuf::Base128, Rubybuf::WireType::Varint)
  end
  describe ".read" do
    context "when read value from reader" do
      it "calls method Rubybuf::Base128#base128_encode_from" do
        stream = StringIO.new("\254\002")
        @klass.read_wiretype_data(stream).should == 300
      end
    end    
  end
  
  describe ".write" do
    context "when write value to writer" do
      it "calls method Rubybuf::Base128#base128_encode_to" do
        stream = StringIO.new
        @klass.write_wiretype_data(stream, 300).should == 2
      end
    end    

  end
end