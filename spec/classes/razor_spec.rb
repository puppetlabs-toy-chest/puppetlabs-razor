require 'spec_helper'

describe 'razor', :type => :class do
  let :facts do
    {
      :operatingsystem => 'RedHat',
      :osfamily => 'RedHat',
      :fqdn => 'razor.example.lan',
    }
  end

  it 'by default' do
    should contain_class 'java'
    should contain_class('razor::tftp').with_server('razor.example.lan')

    should contain_class 'razor::libarchive'
    should contain_class 'razor::torquebox'
    should contain_class 'razor::server'

    should contain_package 'unzip'
    should contain_package 'curl'
  end
end
