require "spec_helper"

describe Rubybuf::Base128 do

  describe ".base128_encode" do

    context "when encode value less than 128" do

      it "returns value.chr" do
        Rubybuf::Base128.base128_encode(120).should == 'x'
      end
    end
    context "when encode value more than 128" do

      it "returns right encoded value" do
        Rubybuf::Base128.base128_encode(300).should == "\254\002"
      end
    end
    context "when encode not integer value" do

      it "raises exception ArgumentError" do
        lambda { Rubybuf::Base128.base128_encode("x") }.should raise_error(::ArgumentError, "value mast by type of Integer")
      end
    end
    context "when encode value les than 0" do

      it "raises exception RangeError" do
        lambda { Rubybuf::Base128.base128_encode(-2) }.should raise_error(::RangeError, "-2 is negative")
      end
    end
  end
  
  describe ".base128_decode" do

    context "when decode one symbol" do

      it "returns value more than 0 and less than 128" do
        Rubybuf::Base128.base128_decode("x").should == 120
      end
    end
    context "when decode a few symbols" do

      it "returns value more than 128" do
        Rubybuf::Base128.base128_decode("\254\002").should == 300
      end
    end
  end
  context "when encode and decode values less than 128" do
    before :all do
      @numbers = []
      50.times do
        @numbers << rand(128)
      end
    end
    
    it "returns original value" do
      @numbers.each do |num|
        Rubybuf::Base128.base128_decode(Rubybuf::Base128.base128_encode(num)).should == num
      end
    end
  end
  context "when encode and decode values more than 128" do
    before :all do
      @numbers = []
      max = 2**32 - 128
      50.times do
        @numbers << rand(max) + 128
      end
    end
    
    it "returns original value" do
      @numbers.each do |num|
        Rubybuf::Base128.base128_decode(Rubybuf::Base128.base128_encode(num)).should == num
      end
    end
  end
end