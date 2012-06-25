require 'spec_helper'

describe 'razor::ruby', :type => :class do
  it { should contain_package('make') }
  [ 'autotest', 'base62', 'bson', 'bson_ext', 'colored',
    'daemons', 'json', 'logger', 'macaddr', 'mocha', 'mongo',
    'net-ssh', 'require_all', 'syntax', 'uuid'
  ].each do |pkg|
    it { should contain_package(pkg).with(
      :ensure   => 'present',
      :provider => 'gem',
      :require  => [ 'Anchor[ruby]', 'Package[make]' ]
    ) }
  end

  # Tests for Debian
  context 'on Debian operatingsystems for 1.9.3' do
    let(:facts) do
      { :operatingsystem => 'Debian' }
    end
    let :params do
      { :version => '1.9.3' }
    end
    it {
      should contain_package('ruby-switch')
      should contain_package('ruby1.9.3')
      should_not contain_package('ruby')
      should_not contain_package('rubygems')
    }
  end

  context 'on Debian operatingsystems for 1.8.7' do
    let(:facts) do
      { :operatingsystem => 'Debian' }
    end
    let :params do
      { :version => '1.8.7' }
    end
    it {
      should contain_package('ruby')
      should contain_package('rubygems')
      should_not contain_package('ruby1.9.3')
      should_not contain_exec('ruby_1.9.3_default')
    }
  end

  # Tests for Ubuntu
  context 'on Ubuntu operatingsystems for 1.9.3' do
    let(:facts) do
      { :operatingsystem => 'Ubuntu',
        :lsbdistcodename => 'precise',
        :path            => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games'
      }
    end
    let :params do
      { :version => '1.9.3' }
    end
    it {
      should contain_package('ruby1.9.3')
      should contain_exec('ruby_1.9.3_default').with(
        :command    => 'update-alternatives --set ruby /usr/bin/ruby1.9.1 && update-alternatives --set gem /usr/bin/gem1.9.1',
        :path       => facts[:path],
        :unless     => 'ruby --version | grep "ruby 1.9"',
        :provider   => 'shell'
      )
      should_not contain_package('ruby')
      should_not contain_package('rubygems')
    }
  end

  context 'on Ubuntu operatingsystems for 1.8.7' do
    let(:facts) do
      { :operatingsystem => 'Ubuntu',
        :lsbdistcodename => 'precise',
        :path            => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games'
      }
    end
    let :params do
      { :version => '1.8.7' }
    end
    it {
      should contain_package('ruby')
      should contain_package('rubygems')
      should_not contain_package('ruby1.9.3')
      should_not contain_exec('ruby_1.9.3_default')
    }
  end
end
