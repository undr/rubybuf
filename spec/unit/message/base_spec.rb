require "spec_helper"
require "messages/all_types"
require "messages/all_rules"

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
  describe " methods #write_to and #read_from" do
    context "in message with all fields types" do
      it "correctly writes values and reads their" do
        message = Rubybuf::AllTypes.new do |m|
          m.id = 12
          m.balance = -1000
          m.price = 1000
          m.is_admin = true
          m.status =  :inactive
          m.name = "Andrey Lepeshkin"
        end

        stream = StringIO.new
        message.write_to(stream)
        stream.pos = 0
        
        message = Rubybuf::AllTypes.new
        message.read_from(stream)
        message.id.should == 12
        message.balance.should == -1000
        message.price.should == 1000
        message.is_admin.should == true
        message.status.should == :inactive
        message.name.should == "Andrey Lepeshkin"
      end
    end
    context "in message with all rules" do
      before(:each) do
        @message =  Rubybuf::AllRules.new do |m|
          m.id = 12
          m.statuses = [:holy, :highest, :aggressive, :sufferer]
        end
      end
      it "correctly writes values (with defaults) and reads their" do
        stream = StringIO.new
        @message.write_to(stream)
        stream.pos = 0
        
        @message = Rubybuf::AllRules.new
        @message.read_from(stream)
        @message.id.should == 12
        @message.name.should == "Unnamed"
        @message.statuses.should include(:holy, :highest, :aggressive, :sufferer)
      end
      it "correctly writes values (without defaults) and reads their" do
        @message.name = "Andrey Lepeshkin"
        stream = StringIO.new
        @message.write_to(stream)
        stream.pos = 0
        
        @message = Rubybuf::AllRules.new
        @message.read_from(stream)
        @message.id.should == 12
        @message.name.should == "Andrey Lepeshkin"
        @message.statuses.should include(:holy, :highest, :aggressive, :sufferer)
      end
    end
  end
end