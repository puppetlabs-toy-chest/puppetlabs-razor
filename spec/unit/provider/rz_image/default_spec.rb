require 'spec_helper'

describe Puppet::Type.type(:rz_image).provider(:default) do
  let :resource do Puppet::Resource.new(:rz_image, 'foo') end
  let :provider do described_class.new(resource) end

  describe "#create" do
    before (:each) do
      provider.should_receive(:download).and_return('foo')
      resource[:source] = '/foo'
    end

    it "with response should return the string" do
      provider.should_receive(:razor).and_return("test")
      provider.create.should == "test"
    end
  end

  describe "#destroy" do
    it "with response should return the string" do
      provider.should_receive(:razor).and_return("")
      provider.destroy.should == ""
    end
  end
end
