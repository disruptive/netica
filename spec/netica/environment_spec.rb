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
  end
end
