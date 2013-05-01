require 'spec_helper'

describe Puppet::Type.type(:rz_model).provider(:default) do
  let :resource do Puppet::Resource.new(:rz_model, 'foo') end
  let :provider do described_class.new(resource) end

  describe "#create" do
    before (:each) do
      # Mock query_razor to return an object with get_image_uuid.
      query_razor = PuppetX::PuppetLabs::Razor.new(nil)
      query_razor.should_receive(:get_image_uuid).and_return('image uuid')
      provider.should_receive(:query_razor).twice.and_return(query_razor)
    end

    it "with response should return the string" do
      provider.should_receive(:razor).and_return(PSON.dump({
        :response => "test",
        }))
      provider.create.should == "test"
    end

    it "with result should raise Puppet::Error" do
      provider.should_receive(:razor).and_return(PSON.dump({
        :result => "Invalid Metadata [root_password:'short']",
        }))
      expect { provider.create }.to raise_error(Puppet::Error)
    end
  end

  describe "#destroy" do
    it "with response should return the string" do
      provider.should_receive(:razor).and_return(PSON.dump({
        :response => "Active Model [7Vu8BbwLUSEGlfqLLxHbYI] removed",
        }))
      provider.destroy.should =~ /removed/
    end

    it "with result should raise Puppet::Error" do
      provider.should_receive(:razor).and_return(PSON.dump({
        :result => "Cannot Find Model with UUID: [7Vu8BbwLUSEGlfqLLxHbYI]",
        }))
      expect { provider.destroy }.to raise_error(Puppet::Error)
    end
  end
end
