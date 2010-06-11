require "spec_helper"

describe Rubybuf::Message::Base do
  [:required, :optional, :repeated].each do |method|
    it "must contain class method ##{method}" do
      Rubybuf::Message::Base.should respond_to(method)
    end
  end
  describe "class methods #required, #optional and #repeated" do
    context "when call once" do
      before(:each) do
        @klass = Class.new(Rubybuf::Message::Base)
      end
      [:required, :optional, :repeated].each do |method|
        it "adds one #{method} field into message class" do
          @klass.send(method, :name, :string, 1)
          @klass.fields.length.should == 1
          @klass.fields.should have(1).items
          @klass.fields[:name].should be_a(Rubybuf::Message::Field::Base)
        end
        it "creates getter and setter methods for each call" do
          message = @klass.new
          message.should_not respond_to(:name, :name=, :age, :age=)
          @klass.send(method, :name, :string, 1)
          @klass.send(method, :age, :int, 2)
          message.should respond_to(:name, :name=, :age, :age=)
        end
      end
    end
    context "when call twice with identical tags" do
      before(:each) do
        @klass = Class .new(Rubybuf::Message::Base)
      end
      [:required, :optional, :repeated].each do |method|
        it "raise error for #{method} field" do
          @klass.send(method, :id, :int, 1)
          lambda { @klass.send(method, :name, :string, 1) }.should raise_error(::StandardError)
        end
      end
    end
    context "when call twice with identical names" do
      before(:each) do
        @klass = Class.new(Rubybuf::Message::Base)
      end
      [:required, :optional, :repeated].each do |method|
        it "raise error for #{method} field" do
          @klass.send(method, :id, :int, 1)
          lambda { @klass.send(method, :id, :string, 2) }.should raise_error(::StandardError)
        end
      end
    end
  end
end