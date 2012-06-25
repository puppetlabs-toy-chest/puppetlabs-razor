require 'spec_helper'

describe 'razor::nodejs', :type => :class do
  let (:params) do
    { :directory => '/var/lib/razor' }
  end

  # Tests for Debian
  context 'on Debian operatingsystems' do
    let(:facts) do
      { :operatingsystem => 'Debian' }
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

  # Tests for Ubuntu
  context 'on Ubuntu operatingsystems' do
    let(:facts) do
      { :operatingsystem => 'Ubuntu',
        :lsbdistcodename => 'precise'
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

  # Tests for RedHat
  context 'on RedHat operatingsystems' do
    let(:facts) do
      { :operatingsystem => 'RedHat' }
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
