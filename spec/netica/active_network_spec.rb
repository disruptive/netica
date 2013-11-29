require 'spec_helper'

describe Netica::ActiveNetwork do

  describe "#new" do
    
    before(:all) do
      Java::NorsysNetica::Environ.__persistent__ = true
      Netica::Environment.engage
    end
    
    after(:all) do
      Netica::Environment.instance.processor.finalize
    end

    context "with ChestClinic.dne" do
      before(:all) do
        @active_network = Netica::ActiveNetwork.new("fake_token_identifier", "#{File.dirname(__FILE__)}/../../examples/ChestClinic.dne")
      end

      it "should be an active network" do
        @active_network.should be_an_instance_of(Netica::ActiveNetwork)
      end

      it "should have 8 nodes" do
        @active_network.network.nodes.length.should == 8
      end

      it "should export its state as a hash" do
        @active_network.network.state.should be_an_instance_of(Hash)
      end
      
      it "should be returned when searched for" do
        Netica::ActiveNetwork.find("fake_token_identifier", false).should === @active_network
      end

      context "the tuberculosis node" do
        it "should be less than 0.02 initially" do
          @active_network.network.node("Tuberculosis").value("present").should be_less_than 0.011
        end

        it "should be over 0.90 with an abnormal xray" do
          @active_network.network.node("XRay").value = "abnormal"
          @active_network.network.node("Tuberculosis").value("present").should be_greater_than 0.092
        end
      end
      
      it "should be deletable" do
        Netica::Environment.instance.active_networks.length.should eq(1)
        outcome = @active_network.destroy
        outcome[:deletion][:memory].should be_true
        outcome[:deletion][:redis].should be_nil
        Netica::Environment.instance.active_networks.length.should eq(0)
      end
    end
  end
  
  context "with redis" do
    before(:all) do
      Java::NorsysNetica::Environ.__persistent__ = true
      redis_settings = { :redis => { :host => "127.0.0.1", :port => 6379 }}
      Netica::Environment.engage(redis_settings)
      @redis = Redis.new(redis_settings)
    end
    
    after(:all) do
      Netica::Environment.instance.processor.finalize
    end
    
    context "with ChestClinic.dne" do
      before(:all) do
        @active_network = Netica::ActiveNetwork.new("fake_token_identifier", "#{File.dirname(__FILE__)}/../../examples/ChestClinic.dne")
        @active_network_token = @active_network.token
      end

      describe "#save" do
        it "should be savable" do
          @redis.get(@active_network_token).should be_nil
          @active_network.save
          @redis.get(@active_network_token).should_not be_nil
        end
      end
    
      describe "#destroy" do
        it "should be deletable" do
          Netica::Environment.instance.active_networks.length.should eq(1)
          @redis.get(@active_network_token).should_not be_nil
          outcome = @active_network.destroy
          outcome[:deletion][:memory].should be_true
          outcome[:deletion][:redis].should be_true
          @redis.get(@active_network_token).should be_nil
          Netica::Environment.instance.active_networks.length.should eq(0)
        end
      end
      
      describe "#destroy_by_token" do
        context "A stored active network" do
          it "should be deletable" do
            @active_network.save
            @active_network.destroy(true, false)
            @redis.get(@active_network_token).should be_true
            
            outcome = Netica::ActiveNetwork.destroy_by_token(@active_network_token)
            outcome[:deletion][:memory].should be_nil
            outcome[:deletion][:redis].should be_true
            
            @redis.get(@active_network_token).should be_nil
            Netica::Environment.instance.active_networks.length.should eq(0)
          end
        end
      end
    end
  end
end

