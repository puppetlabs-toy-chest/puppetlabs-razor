require 'spec_helper'

describe 'razor', :type => :class do
  let (:params) do
    { :username  => 'blade',
      :directory => '/var/lib/razor',
      :persist_host => '127.0.0.1',
      :mk_checkin_interval => '60',
    }
  end

  context 'on Debian operatingsystems' do
    let(:facts) do
      { :osfamily        => 'Debian',
        :operatingsystem => 'Debian',
        :ipaddress       => '10.13.1.3',
      }
    end
    it {
      should include_class('mongodb')
      should include_class('sudo')
      should contain_class('razor::nodejs').with(
        :directory => params[:directory]
      )
      should include_class('razor::tftp')
      should contain_file('/srv/tftp/razor.ipxe').with(
        :content => /http:\/\/#{facts[:ipaddress]}:8026\/razor\/api\/boot\?hw_id=\$\{net0\/mac\}/
      )
      should include_class('razor::ruby')
      should contain_user(params[:username]).with(
        :ensure => 'present',
        :gid    => params[:username],
        :home   => params[:directory]
      )
      should contain_group(params[:username]).with(
        :ensure => 'present'
      )
      should contain_sudo__conf('razor').with(
        :priority => '10',
        :content  => /#{params[:username]} ALL=\(root\)/
      )
      should contain_package('git').with( :ensure => 'present' )
      should contain_vcsrepo(params[:directory]).with(
        :ensure   => 'latest',
        :provider => 'git',
        :source   => 'http://github.com/puppetlabs/Razor.git'
      )
      should contain_file(params[:directory]).with(
        :ensure => 'directory',
        :mode   => '0755',
        :owner  => params[:username],
        :group  => params[:username]
      )
      should contain_service('razor').with(
        :ensure => 'running',
        :hasstatus => true,
        :status => "/var/lib/razor/bin/razor_daemon.rb status",
        :start => "/var/lib/razor/bin/razor_daemon.rb start",
        :stop => "/var/lib/razor/bin/razor_daemon.rb stop",
        :require => ['Class[Mongodb]', 'File[/var/lib/razor]', 'Sudo::Conf[razor]'],
        :subscribe => ['Class[Razor::Nodejs]', "Vcsrepo[#{params[:directory]}]"]
      )
      should contain_file("#{params[:directory]}/conf/razor_server.conf").with(
        :ensure  => 'file',
        :content => /image_svc_host: #{facts[:ipaddress]}/,
        :content => /image_svc_path: #{params[:directory]}\/image/,
        :content => /mk_uri: http:\/\/#{facts[:ipaddress]}:8026/,
        :content => /mk_checkin_interval: #{params[:mk_checkin_interval]}/,
        :content => /persist_host: #{params[:persist_host]}/,
        :notify  => 'Service[razor]'
      )
     }
  end

  context 'on Ubuntu operatingsystems' do
    let(:facts) do
      { :osfamily        => 'Debian',
        :operatingsystem => 'Ubuntu',
        :lsbdistcodename => 'precise'
      }
    end
    it {
      should include_class('mongodb')
      should include_class('sudo')
      should contain_class('razor::nodejs').with(
        :directory => params[:directory]
      )
      should include_class('razor::tftp')
      should contain_file('/var/lib/tftpboot/razor.ipxe').with(
        :content => /http:\/\/#{facts[:ipaddress]}:8026\/razor\/api\/boot\?hw_id=\$\{net0\/mac\}/
      )
      should include_class('razor::ruby')
      should contain_user(params[:username]).with(
        :ensure => 'present',
        :gid    => params[:username],
        :home   => params[:directory]
      )
      should contain_group(params[:username]).with(
        :ensure => 'present'
      )
      should contain_sudo__conf('razor').with(
        :priority => '10',
        :content  => /#{params[:username]} ALL=\(root\)/
      )
      should contain_package('git').with(
        :ensure => 'present'
      )
      should contain_vcsrepo(params[:directory]).with(
        :ensure   => 'latest',
        :provider => 'git',
        :source   => 'http://github.com/puppetlabs/Razor.git'
      )
      should contain_file(params[:directory]).with(
        :ensure => 'directory',
        :mode   => '0755',
        :owner  => params[:username],
        :group  => params[:username]
      )
      should contain_service('razor').with(
        :ensure => 'running',
        :hasstatus => true,
        :status => "/var/lib/razor/bin/razor_daemon.rb status",
        :start => "/var/lib/razor/bin/razor_daemon.rb start",
        :stop => "/var/lib/razor/bin/razor_daemon.rb stop",
        :require => ['Class[Mongodb]', 'File[/var/lib/razor]', 'Sudo::Conf[razor]'],
        :subscribe => ['Class[Razor::Nodejs]', 'Vcsrepo[/var/lib/razor]']
      )
      should contain_file("#{params[:directory]}/conf/razor_server.conf").with(
        :ensure  => 'file',
        :content => /image_svc_host: #{facts[:ipaddress]}/,
        :content => /image_svc_path: #{params[:directory]}\/image/,
        :content => /mk_uri: http:\/\/#{facts[:ipaddress]}:8026/,
        :content => /mk_checkin_interval: #{params[:mk_checkin_interval]}/,
        :content => /persist_host: #{params[:persist_host]}/,
        :notify  => 'Service[razor]'
      )
   }
  end

  context 'on RedHat operatingsystems' do
    let(:facts) do
      { :osfamily        => 'RedHat',
        :operatingsystem => 'RedHat' }
    end
    it do
    end
  end
end
