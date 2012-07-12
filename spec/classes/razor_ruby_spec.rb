require 'spec_helper'

describe 'razor::ruby', :type => :class do
  it {
    should contain_package('make')
    should include_class('ruby')
  }
  [ 'autotest', 'base62', 'bson', 'bson_ext', 'colored',
    'daemons', 'json', 'logger', 'macaddr', 'mocha', 'mongo',
    'net-ssh', 'require_all', 'syntax', 'uuid'
  ].each do |pkg|
    it {
      should contain_package(pkg).with(
        :ensure   => 'present',
        :provider => 'gem',
        :require  => [ 'Class[Ruby]', 'Package[make]' ]
      )
    }
  end
end
