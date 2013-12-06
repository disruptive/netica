require 'spec_helper'

describe StorableNetwork do
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
        @active_network = StorableNetwork.new("storable_fake_token_identifier", "#{File.dirname(__FILE__)}/../../examples/ChestClinic.dne")
        @active_network_token = @active_network.token
      end
      
      after(:all) do
        @redis.del("storable_fake_token_identifier")
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
            
            outcome = StorableNetwork.destroy_by_token(@active_network_token)
            outcome[:deletion][:memory].should be_nil
            outcome[:deletion][:redis].should be_true
            
            @redis.get(@active_network_token).should be_nil
            Netica::Environment.instance.active_networks.length.should eq(0)
          end
        end
      end
      
      describe "#find" do
        it "should be reloadable" do
          @active_network.network.node("Tuberculosis").value("present").should be_less_than 0.011
          @active_network.network.node("XRay").value = "abnormal"

          @active_network.network.node("Tuberculosis").value("present").should be_greater_than 0.092
          @active_network.save
          
          @active_network.destroy(true, false)
          
          Netica::Environment.instance.active_networks.length.should eq(0)
          
          @reloaded_network = StorableNetwork.find(@active_network_token, true)
          Netica::Environment.instance.active_networks.length.should eq(1)
          
          @reloaded_network.network.node("Tuberculosis").value("present").should be_greater_than 0.092
          
          @reloaded_network.destroy
          Netica::Environment.instance.active_networks.length.should eq(0)
        end
      end
    end
  end
end

