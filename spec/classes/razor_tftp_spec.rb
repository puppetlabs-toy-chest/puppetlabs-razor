require 'spec_helper'

describe 'razor::tftp', :type => :class do
  # Tests for Debian
  context 'on Debian operatingsystems' do
    let(:facts) do
      { :operatingsystem => 'Debian',
        :ipaddress       => '10.13.1.3'
      }
    end
    it { should include_class('tftp') }
    it { should contain_tftp__file('pxelinux.0').with(
      :source => 'puppet:///modules/razor/pxelinux.0')
    }
    it { should contain_tftp__file('pxelinux.cfg').with(
      :ensure => 'directory')
    }
    it { should contain_tftp__file('pxelinux.cfg/default').with(
      :source => 'puppet:///modules/razor/default')
    }
    it { should contain_tftp__file('menu.c32').with(
      :source => 'puppet:///modules/razor/menu.c32')
    }
    it { should contain_tftp__file('ipxe.iso').with(
      :source => 'puppet:///modules/razor/ipxe.iso')
    }
    it { should contain_tftp__file('ipxe.lkrn').with(
      :source => 'puppet:///modules/razor/ipxe.lkrn')
    }
    it { should contain_tftp__file('razor.ipxe').with(
      :content => /http:\/\/#{facts[:ipaddress]}:8026\/razor\/api\/boot\?mac=\$\{net0\/mac\}/)
    }
  end

  # Tests for Ubuntu
  context 'on Ubuntu operatingsystems' do
    let(:facts) do
      { :operatingsystem => 'Ubuntu',
        :lsbdistcodename => 'precise'
      }
    end
    it { should include_class('tftp') }
    it { should contain_tftp__file('pxelinux.0').with(
      :source => 'puppet:///modules/razor/pxelinux.0')
    }
    it { should contain_tftp__file('pxelinux.cfg').with(
      :ensure => 'directory')
    }
    it { should contain_tftp__file('pxelinux.cfg/default').with(
      :source => 'puppet:///modules/razor/default')
    }
    it { should contain_tftp__file('menu.c32').with(
      :source => 'puppet:///modules/razor/menu.c32')
    }
    it { should contain_tftp__file('ipxe.iso').with(
      :source => 'puppet:///modules/razor/ipxe.iso')
    }
    it { should contain_tftp__file('ipxe.lkrn').with(
      :source => 'puppet:///modules/razor/ipxe.lkrn')
    }
    it { should contain_tftp__file('razor.ipxe').with(
      :content => /http:\/\/#{facts[:ipaddress]}:8026\/razor\/api\/boot\?mac=\$\{net0\/mac\}/)
    }
  end

  # Tests on RedHat
  context 'on RedHat operatingsystems' do
    let(:facts) do
      { :operatingsystem => 'RedHat',
        :ipaddress       => '10.13.1.3'
      }
    end
    it { should include_class('tftp') }
    it { should contain_tftp__file('pxelinux.0').with(
      :source => 'puppet:///modules/razor/pxelinux.0')
    }
    it { should contain_tftp__file('pxelinux.cfg').with(
      :ensure => 'directory')
    }
    it { should contain_tftp__file('pxelinux.cfg/default').with(
      :source => 'puppet:///modules/razor/default')
    }
    it { should contain_tftp__file('menu.c32').with(
      :source => 'puppet:///modules/razor/menu.c32')
    }
    it { should contain_tftp__file('ipxe.iso').with(
      :source => 'puppet:///modules/razor/ipxe.iso')
    }
    it { should contain_tftp__file('ipxe.lkrn').with(
      :source => 'puppet:///modules/razor/ipxe.lkrn')
    }
    it { should contain_tftp__file('razor.ipxe').with(
      :content => /http:\/\/#{facts[:ipaddress]}:8026\/razor\/api\/boot\?mac=\$\{net0\/mac\}/)
    }
  end
end
