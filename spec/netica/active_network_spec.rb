require 'spec_helper'

describe Netica::ActiveNetwork do
  describe "#new" do
    before(:all) do
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

      context "the tuberculosis node" do
        it "should be less than 0.02 initially" do
          @active_network.network.node("Tuberculosis").value("present").should be_less_than 0.011
        end

        it "should be over 0.90 with an abnormal xray" do
          @active_network.network.node("XRay").value = "abnormal"
          @active_network.network.node("Tuberculosis").value("present").should be_greater_than 0.092
        end
      end
    end
  end
end

