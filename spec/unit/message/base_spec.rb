require "spec_helper"

describe Rubybuf::Message::Base do
  it "must contain class method #required" do
    Rubybuf::Message::Base.should respond_to(:required)
  end
  it "must contain class method #optional" do
    Rubybuf::Message::Base.should respond_to(:optional)
  end
  it "must contain class method #repeated" do
    Rubybuf::Message::Base.should respond_to(:repeated)
  end
  describe "class methods #required, #optional and #repeated" do
    context "when call once" do
      after(:each) do
        Rubybuf::Message::Base.clear_fields
      end
      it "add one required field into message class" do
        Rubybuf::Message::Base.required(:name, :string, 1)
        Rubybuf::Message::Base.fields.length.should == 1
        Rubybuf::Message::Base.fields.should have(1).items
        Rubybuf::Message::Base.fields[:name].should be_a(Rubybuf::Message::Field)
      end
      it "add one optional field into message class" do
        Rubybuf::Message::Base.optional(:name, :string, 1)
        Rubybuf::Message::Base.fields.length.should == 1
        Rubybuf::Message::Base.fields.should have(1).items
        Rubybuf::Message::Base.fields[:name].should be_a(Rubybuf::Message::Field)
      end
      it "add one repeated field into message class" do
        Rubybuf::Message::Base.repeated(:name, :string, 1)
        Rubybuf::Message::Base.fields.length.should == 1
        Rubybuf::Message::Base.fields.should have(1).items
        Rubybuf::Message::Base.fields[:name].should be_a(Rubybuf::Message::Field)
      end
    end
    context "when call twice with identical tags" do
      after(:each) do
        Rubybuf::Message::Base.clear_fields
      end
      it "raise error for required field" do
        Rubybuf::Message::Base.required(:id, :int, 1)
        lambda { Rubybuf::Message::Base.required(:name, :string, 1) }.should raise_error(::StandardError)
      end
      it "raise error for optional field" do
        Rubybuf::Message::Base.optional(:id, :int, 1)
        lambda { Rubybuf::Message::Base.optional(:name, :string, 1) }.should raise_error(::StandardError)
      end
      it "raise error for repeated field" do
        Rubybuf::Message::Base.repeated(:id, :int, 1)
        lambda { Rubybuf::Message::Base.repeated(:name, :string, 1) }.should raise_error(::StandardError)
      end
    end
    context "when call twice with identical names" do
      after(:each) do
        Rubybuf::Message::Base.clear_fields
      end
      it "raise error for required field" do
        Rubybuf::Message::Base.required(:id, :int, 1)
        lambda { Rubybuf::Message::Base.required(:id, :string, 2) }.should raise_error(::StandardError)
      end
      it "raise error for optional field" do
        Rubybuf::Message::Base.optional(:id, :int, 1)
        lambda { Rubybuf::Message::Base.optional(:id, :string, 2) }.should raise_error(::StandardError)
      end
      it "raise error for repeated field" do
        Rubybuf::Message::Base.repeated(:id, :int, 1)
        lambda { Rubybuf::Message::Base.repeated(:id, :string, 2) }.should raise_error(::StandardError)
      end
    end
  end
end