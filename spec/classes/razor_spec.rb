require 'spec_helper'

describe 'razor', :type => :class do
  let (:params) do
    {
      :username            => 'blade',
      :directory           => '/var/lib/razor',
      :persist_host        => '127.0.0.1',
      :mk_checkin_interval => '60',
      :git_source          => 'http://github.com/johndoe/Razor.git',
      :git_revision        => '1ef7d2',
      :server_opts_hash    => { 'mk_log_level' => 'Logger::DEBUG' },
    }
  end

  [ { :osfamily  => 'Debian',
      :path      => '/srv/tftp', },
    { :osfamily  => 'Debian',
      :os        => 'Ubuntu',
      :lsb       => 'precise',
      :path      => '/var/lib/tftpboot' },
    { :osfamily  => 'RedHat',
      :path      => '/var/lib/tftpboot' },
  ].each do |platform|
    context "on #{platform[:os] || platform[:osfamily]} operatingsystems" do
      let(:facts) do
        { :osfamily        => platform[:osfamily],
          :operatingsystem => platform[:os] || platform[:osfamily],
          :lsbdistcodename => platform[:lsb] || :undef,
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
          :source   => params[:git_source],
          :revision => params[:git_revision]
        )
        should contain_file(params[:directory]).with(
          :ensure => 'directory',
          :mode   => '0755',
          :owner  => params[:username],
          :group  => params[:username]
        )
        should contain_service('razor').with(
          :ensure    => 'running',
          :hasstatus => true,
          :status    => "/var/lib/razor/bin/razor_daemon.rb status",
          :start     => "/var/lib/razor/bin/razor_daemon.rb start",
          :stop      => "/var/lib/razor/bin/razor_daemon.rb stop",
          :require   => ['Class[Mongodb]', 'File[/var/lib/razor]', 'Sudo::Conf[razor]'],
          :subscribe => ['Class[Razor::Nodejs]', "Vcsrepo[#{params[:directory]}]"]
        )
        should contain_file("#{params[:directory]}/conf/razor_server.conf").with(
          :ensure  => 'file',
          :content => /image_svc_host: #{facts[:ipaddress]}/,
          :content => /image_svc_path: #{params[:directory]}\/image/,
          :content => /mk_uri: http:\/\/#{facts[:ipaddress]}:8026/,
          :content => /mk_checkin_interval: #{params[:mk_checkin_interval]}/,
          :content => /persist_host: #{params[:persist_host]}/,
          :content => /mk_log_level: #{params[:server_opts_hash]['mk_log_level']}/,
          :notify  => 'Service[razor]'
        )
        should contain_exec('gen_ipxe').with_command("#{params[:directory]}/bin/razor config ipxe > #{params[:directory]}/conf/razor.ipxe.source")
        should contain_exec('gen_ipxe').with(
          :subscribe => "File[#{params[:directory]}/conf/razor_server.conf]"
        )
        should contain_file("#{platform[:path]}/razor.ipxe").with(
          :source => "#{params[:directory]}/conf/razor.ipxe.source",
          :subscribe => 'Exec[gen_ipxe]'
        )
      }
    end
  end
end
