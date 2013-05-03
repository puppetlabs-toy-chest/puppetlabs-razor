require 'spec_helper'

describe Puppet::Type.type(:rz_broker).provider(:default) do
  let :resource do Puppet::Resource.new(:rz_broker, 'foo') end
  let :provider do described_class.new(resource) end

  describe "#create" do
    it "with response should return the string" do
      provider.should_receive(:razor).and_return(PSON.dump({
        :response => "test",
        }))
      provider.create.should == "test"
    end

    it "with result should raise Puppet::Error" do
      provider.should_receive(:razor).and_return(PSON.dump({
        :result => "Must Provide: [The broker plugin to use.]",
        }))
      expect { provider.create }.to raise_error(Puppet::Error)
    end
  end

  describe "#destroy" do
    it "with response should return the string" do
      provider.should_receive(:razor).and_return(PSON.dump({
        :response => "Broker [5QRpDwF2w8kuT8ROh1W7p4] removed",
        }))
      provider.destroy.should =~ /removed/
    end

    it "with result should raise Puppet::Error" do
      provider.should_receive(:razor).and_return(PSON.dump({
        :result => "Cannot Find Broker with UUID: [5QRpDwF2w8kuT8ROh1W7p4]",
        }))
      expect { provider.destroy }.to raise_error(Puppet::Error)
    end
  end
end
