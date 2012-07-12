require 'spec_helper'

describe 'razor::tftp', :type => :class do
  # Tests for Debian
  context 'on Debian operatingsystems' do
    let(:facts) do
      { :osfamily        => 'Debian',
        :operatingsystem => 'Debian',
        :ipaddress       => '10.13.1.3'
      }
    end
    it {
      should include_class('tftp')
      should contain_file('/srv/tftp/pxelinux.0').with(
        :source => 'puppet:///modules/razor/pxelinux.0'
      )
      should contain_file('/srv/tftp/pxelinux.cfg').with(
        :ensure => 'directory',
        :source  => 'puppet:///modules/razor/pxelinux.cfg',
        :recurse => true
      )
      should contain_file('/srv/tftp/menu.c32').with(
        :source => 'puppet:///modules/razor/menu.c32'
      )
      should contain_file('/srv/tftp/ipxe.iso').with(
        :source => 'puppet:///modules/razor/ipxe.iso'
      )
      should contain_file('/srv/tftp/ipxe.lkrn').with(
        :source => 'puppet:///modules/razor/ipxe.lkrn'
      )
    }
  end

  # Tests for Ubuntu
  context 'on Ubuntu operatingsystems' do
    let(:facts) do
      { :osfamily        => 'Debian',
        :operatingsystem => 'Ubuntu',
        :lsbdistcodename => 'precise'
      }
    end
    it {
      should include_class('tftp')
      should contain_file('/var/lib/tftpboot/pxelinux.0').with(
        :source => 'puppet:///modules/razor/pxelinux.0'
      )
      should contain_file('/var/lib/tftpboot/pxelinux.cfg').with(
        :ensure  => 'directory',
        :source  => 'puppet:///modules/razor/pxelinux.cfg',
        :recurse => true
      )
      should contain_file('/var/lib/tftpboot/menu.c32').with(
        :source => 'puppet:///modules/razor/menu.c32'
      )
      should contain_file('/var/lib/tftpboot/ipxe.iso').with(
        :source => 'puppet:///modules/razor/ipxe.iso'
      )
      should contain_file('/var/lib/tftpboot/ipxe.lkrn').with(
        :source => 'puppet:///modules/razor/ipxe.lkrn'
      )
    }
  end

  # Tests on RedHat
  context 'on RedHat operatingsystems' do
    let(:facts) do
      { :osfamily        => 'RedHat',
        :operatingsystem => 'RedHat',
        :ipaddress       => '10.13.1.3'
      }
    end
    it {
      should include_class('tftp')
      should contain_file('/var/lib/tftpboot/pxelinux.0').with(
        :source => 'puppet:///modules/razor/pxelinux.0'
      )
      should contain_file('/var/lib/tftpboot/pxelinux.cfg').with(
        :ensure => 'directory',
        :source  => 'puppet:///modules/razor/pxelinux.cfg',
        :recurse => true
      )
      should contain_file('/var/lib/tftpboot/menu.c32').with(
        :source => 'puppet:///modules/razor/menu.c32'
      )
      should contain_file('/var/lib/tftpboot/ipxe.iso').with(
        :source => 'puppet:///modules/razor/ipxe.iso'
      )
      should contain_file('/var/lib/tftpboot/ipxe.lkrn').with(
        :source => 'puppet:///modules/razor/ipxe.lkrn'
      )
    }
  end
end
