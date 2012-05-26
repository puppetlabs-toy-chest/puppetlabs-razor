require 'spec_helper'

describe 'razor::ruby19', :type => :class do
  it { should contain_package('ruby1.9.3') }
  it { should contain_package('make') }
  it { should contain_package('macaddr').with(
    :ensure   => '1.5.0',
    :provider => 'gem')
  }
  it { should contain_package('uuid').with(
    :ensure   => 'present',
    :provider => 'gem')
  }
  [ 'autotest', 'base62', 'bluepill', 'bson', 'bson_ext',
    'colored', 'extlib', 'json', 'logger', 'mocha', 'mongo',
    'net-ssh', 'redcarpet', 'require_all', 'rspec', 'syntax'
  ].each do |pkg|
    it { should contain_package(pkg).with(
      :ensure   => 'present',
      :provider => 'gem')
    }
  end

  # Tests for Debian
  context 'on Debian operatingsystems' do
    let(:facts) do
      { :operatingsystem => 'Debian' }
    end
    it { should contain_package('ruby-switch') }
  end

  # Tests for Ubuntu
  context 'on Ubuntu operatingsystems' do
    let(:facts) do
      { :operatingsystem => 'Ubuntu',
        :lsbdistcodename => 'precise',
        :path            => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games'
      }
    end
    it { should contain_exec('ruby_1.9.3_default').with(
      :command    => 'update-alternatives --set ruby /usr/bin/ruby1.9.1 && update-alternatives --set gem /usr/bin/gem1.9.1',
      :path       => facts[:path],
      :unless     => 'ruby --version | grep "ruby 1.9"',
      :provider   => 'shell')
    }
  end
end
