require 'spec_helper'

describe 'razor', :type => :class do
  let (:params) do
    { :username  => 'blade',
      :directory => '/var/lib/razor',
    }
  end

  # Tests for Debian
  context 'on Debian operatingsystems' do
    let(:facts) do
      { :operatingsystem => 'Debian' }
    end
    it { should include_class('mongodb') }
    it { should include_class('sudo') }
    it { should contain_class('razor::nodejs').with(
      :directory => params[:directory])
    }
    it { should include_class('razor::tftp') }
    it { should include_class('razor::ruby') }
    it { should contain_user(params[:username]).with(
      :ensure => 'present',
      :gid    => params[:username],
      :home   => params[:directory] )
    }
    it { should contain_group(params[:username]).with(
      :ensure => 'present' )
    }
    it { should contain_sudo__conf('razor').with(
      :priority => '10',
      :content  => /#{params[:username]} ALL=\(root\)/ )
    }
    it { should contain_package('git').with(
      :ensure => 'present' )
    }
    it { should contain_vcsrepo(params[:directory]).with(
      :ensure   => 'latest',
      :provider => 'git',
      :source   => 'git://github.com/puppetlabs/Razor.git')
    }
    it { should contain_file(params[:directory]).with(
      :ensure => 'directory',
      :mode   => '0755',
      :owner  => params[:username],
      :group  => params[:username])
    }
  end

  # Tests for Ubuntu
  context 'on Ubuntu operatingsystems' do
    let(:facts) do
      { :operatingsystem => 'Ubuntu',
        :lsbdistcodename => 'precise'
      }
    end
    it { should include_class('mongodb') }
    it { should include_class('sudo') }
    it { should contain_class('razor::nodejs').with(
      :directory => params[:directory])
    }
    it { should include_class('razor::tftp') }
    it { should include_class('razor::ruby') }
    it { should contain_user(params[:username]).with(
      :ensure => 'present',
      :gid    => params[:username],
      :home   => params[:directory] )
    }
    it { should contain_group(params[:username]).with(
      :ensure => 'present' )
    }
    it { should contain_sudo__conf('razor').with(
      :priority => '10',
      :content  => /#{params[:username]} ALL=\(root\)/ )
    }
    it { should contain_package('git').with(
      :ensure => 'present' )
    }
    it { should contain_vcsrepo(params[:directory]).with(
      :ensure   => 'latest',
      :provider => 'git',
      :source   => 'git://github.com/puppetlabs/Razor.git')
    }
    it { should contain_file(params[:directory]).with(
      :ensure => 'directory',
      :mode   => '0755',
      :owner  => params[:username],
      :group  => params[:username])
    }
  end

  # Tests for RedHat
  context 'on Ubuntu operatingsystems' do
    let(:facts) do
      { :operatingsystem => 'RedHat' }
    end
    it do
      expect { should include_class('mongodb')
      }.to raise_error(Puppet::Error, /operatingsystem #{facts[:operatingsystem]} is not supported/)
    end
  end
end
