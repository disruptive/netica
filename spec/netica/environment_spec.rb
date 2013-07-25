require 'spec_helper'

describe Netica::Environment do
  describe "#engage" do
    it 'should create a Netica environment' do
      Netica::Environment.engage.should be_true
      Netica::Environment.instance.processor.finalize
    end

    it 'should create a logfile' do
      Netica::Environment.engage
      Netica::NeticaLogger.info "Test logfile entry"
      Netica::Environment.instance.processor.finalize
    end
    
    context "with a specified storage container" do
      it 'should store active_networks in the storage container' do
        @active_networks = []
        Netica::Environment.engage(:network_container => @active_networks)
        Netica::ActiveNetwork.new("fake_token_identifier", "#{File.dirname(__FILE__)}/../../examples/ChestClinic.dne")
        @active_networks.length.should == 1
        Netica::Environment.instance.processor.finalize
      end
    end
  end
end
