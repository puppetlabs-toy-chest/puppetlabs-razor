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
        :response => ""
        }))
      provider.destroy.should == ""
    end

    it "with result should raise Puppet::Error" do
      provider.should_receive(:razor).and_return(PSON.dump({
        :result => "invalid uuid [\"3qP9NNmv6xTIMfTpoP5k6M\"]",
        }))
      expect { provider.destroy }.to raise_error(Puppet::Error)
    end
  end
end
