require 'spec_helper'

describe 'razor::tftp', :type => :class do

  [ { :osfamily  => 'Debian',
      :path      => '/srv/tftp' },
    { :osfamily  => 'Debian',
      :os        => 'Ubuntu',
      :path      => '/var/lib/tftpboot' },
    { :osfamily  => 'RedHat',
      :path      => '/var/lib/tftpboot' },
  ].each do |platform|
    context "on #{platform[:os] || platform[:osfamily]} operatingsystems" do
      let(:facts) do
        { :osfamily        => platform[:osfamily],
          :operatingsystem => platform[:os] || platform[:osfamily],
          :ipaddress       => '10.13.1.3'
        }
      end
      it {
        should include_class('tftp')
        should contain_file("#{platform[:path]}/pxelinux.0").with(
          :source => 'puppet:///modules/razor/pxelinux.0'
        )
        should contain_file("#{platform[:path]}/pxelinux.cfg").with(
          :ensure => 'directory',
          :source  => 'puppet:///modules/razor/pxelinux.cfg',
          :recurse => true
        )
        should contain_file("#{platform[:path]}/menu.c32").with(
          :source => 'puppet:///modules/razor/menu.c32'
        )
        should contain_file("#{platform[:path]}/ipxe.iso").with(
          :source => 'puppet:///modules/razor/ipxe.iso'
        )
        should contain_file("#{platform[:path]}/ipxe.lkrn").with(
          :source => 'puppet:///modules/razor/ipxe.lkrn'
        )
      }
    end
  end

end
