require 'spec_helper'

describe Puppet::Type.type(:rz_policy).provider(:default) do
  let :resource do Puppet::Resource.new(:rz_policy, 'foo') end
  let :provider do described_class.new(resource) end

  describe "#create" do
    before (:each) do
      # Mock query_razor to return an object with get_model_uuid and get_broker_uuid.
      query_razor = PuppetX::PuppetLabs::Razor.new(nil)
      query_razor.should_receive(:get_model_uuid).and_return('model uuid')
      query_razor.should_receive(:get_broker_uuid).and_return('broker uuid')
      provider.should_receive(:query_razor).exactly(3).times.and_return(query_razor)
    end

    it "with response should return the string" do
      provider.should_receive(:razor).and_return(PSON.dump({
        :response => "test",
        }))
      provider.create.should == "test"
    end

    it "with result should raise Puppet::Error" do
      provider.should_receive(:razor).and_return(PSON.dump({
        :result => "Policy Template is not valid [foo]",
        }))
      expect { provider.create }.to raise_error(Puppet::Error)
    end
  end

  describe "#destroy" do
    it "with response should return the string" do
      provider.should_receive(:razor).and_return(PSON.dump({
        :response => "Active policy [5VtQrjhwifUskC0wnDk2OI] removed",
        }))
      provider.destroy.should =~ /removed/
    end

    it "with result should raise Puppet::Error" do
      provider.should_receive(:razor).and_return(PSON.dump({
        :result => "Cannot Find Policy with UUID: [5VtQrjhwifUskC0wnDk2OI]",
        }))
      expect { provider.destroy }.to raise_error(Puppet::Error)
    end
  end
end
