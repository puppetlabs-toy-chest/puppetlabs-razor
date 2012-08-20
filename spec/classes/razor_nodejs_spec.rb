require 'spec_helper'

describe 'razor::nodejs', :type => :class do
  let (:params) do
    { :directory => '/var/lib/razor' }
  end

  [ { :os  => 'Debian',
      :lsb => :undef, },
    { :os  => 'Ubuntu',
      :lsb => 'precise', },
    { :os  => 'RedHat',
      :lsb => :undef, }
  ].each do |platform|
    context "on #{platform[:os]} operatingsystems" do
      let(:facts) do
        { :operatingsystem => platform[:os],
          :lsbdistcodename => platform[:lsb],
        }
      end
      it {
        should contain_package('express').with(
          :ensure   => 'present',
          :provider => 'npm'
        )
        should include_class('nodejs')
        should contain_nodejs__npm("#{params[:directory]}:express")
        should contain_nodejs__npm("#{params[:directory]}:mime")
      }
    end
  end

  # Tests for an unsupported OS (Darwin)
  context 'on Darwin operatingsystems' do
    let(:facts) do
      { :operatingsystem => 'Darwin' }
    end
    it do
      expect { should include_class('nodejs') }.to raise_error(
        Puppet::Error, /Class nodejs does not support #{params[:operatingsystem]}/
      )
    end
  end
end
