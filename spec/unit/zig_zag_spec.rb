require "spec_helper"

describe Rubybuf::ZigZag do

  describe ".zigzag_encode" do
    context "when encode not integer value" do

      it "raises exception ArgumentError" do
        lambda { Rubybuf::ZigZag.zigzag_encode("x") }.should raise_error(::ArgumentError, "value must by type of Integer")
      end
    end
    context "when encode positive value" do

      it "returns value * 2" do
        Rubybuf::ZigZag.zigzag_encode(120).should == (120 *2)
      end
    end
    context "when encode negative value" do

      it "returns abs(value * 2) - 1 " do
        Rubybuf::ZigZag.zigzag_encode(-120).should == ((-120 * 2).abs - 1)
      end
    end
  end
  
  describe ".zigzag_decode" do
    context "when encode not integer value" do

      it "raises exception ArgumentError" do
        lambda { Rubybuf::ZigZag.zigzag_decode("x") }.should raise_error(::ArgumentError, "value must by type of Integer")
      end
    end
    context "when decode positive value" do

      it "returns positive values for even integers" do
        Rubybuf::ZigZag.zigzag_decode(300).should == 150
      end
      it "returns negative value for odd integers" do
        Rubybuf::ZigZag.zigzag_decode(301).should == -150
      end
    end
    context "when encode negative value" do

      it "raises exception RangeError" do
        lambda { Rubybuf::ZigZag.zigzag_decode(-2) }.should raise_error(::RangeError, "-2 is negative")
      end
    end
  end
end