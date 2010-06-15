require "spec_helper"
require "messages/all_types"
require "messages/all_rules"
require "messages/nested_message"
require "messages/with_default_values"

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
  describe ".clear!" do
    context "without default values" do
      it "clears values of message" do
        message = Rubybuf::AllTypes.new do |m|
          m.id = 12
          m.balance = -1000
          m.price = 1000
          m.is_admin = true
          m.status =  :inactive
          m.name = "Andrey Lepeshkin"
        end
        message.id.should == 12
        message.balance.should == -1000
        message.price.should == 1000
        message.is_admin.should == true
        message.status.should == :inactive
        message.name.should == "Andrey Lepeshkin"   

        message.clear!

        message.id.should == nil
        message.balance.should == nil
        message.price.should == nil
        message.is_admin.should == nil
        message.status.should == nil
        message.name.should == nil  
      end
    end
    context "with default values" do
      it "clears values of message and sets default values" do
        message = Rubybuf::WithDefaultValues.new do |m|
          m.id = 12
          m.name = "Undr"
          m.gender = :male
          m.statuses = [:positive, :holy]
        end
        message.id.should == 12
        message.gender.should == :male
        message.name.should == "Undr"
        message.statuses.should == [:positive, :holy]  

        message.clear!

        message.id.should == nil
        message.gender.should == :neuter
        message.name.should == "Unnamed"
        message.statuses.should == [:holy, :highest, :positive] 
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
        
        @message = Rubybuf::AllRules.new
        @message.read_from(stream)
        @message.id.should == 12
        @message.name.should == "Andrey Lepeshkin"
        @message.statuses.should include(:holy, :highest, :aggressive, :sufferer)
      end
    end
    context "in nested messages" do
      it "correctly writes nested messages and reads their" do
        
        ch1 =  Rubybuf::AllRules.new(:id => 12, :statuses => [:holy, :sufferer])
        ch2 =  Rubybuf::AllRules.new(:id => 13, :statuses => [:holy, :aggressive])
        ch3 =  Rubybuf::AllRules.new(:id => 14, :statuses => [:damned, :lowest])
        ch4 =  Rubybuf::AllRules.new(:id => 15, :statuses => [:damned, :aggressive])
        
        message = Rubybuf::NestedMessage.new do |m|
          m.id = 300000
          m.child << ch1
          m.child << ch2
          m.child << ch3
          m.child << ch4
        end
        stream = StringIO.new
        message.write_to(stream)
        
        message = Rubybuf::NestedMessage.new
        message.read_from(stream)
        message.id.should == 300000
        message.child.should have(4).messages
        message.child[0].id.should == 12
        message.child[0].statuses.should include(:holy, :sufferer)
        message.child[1].id.should == 13
        message.child[1].statuses.should include(:holy, :aggressive)
        message.child[2].id.should == 14
        message.child[2].statuses.should include(:damned, :lowest)
        message.child[3].id.should == 15
        message.child[3].statuses.should include(:damned, :aggressive)
      end
    end
  end
end