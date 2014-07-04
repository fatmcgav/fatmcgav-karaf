require 'spec_helper'

describe 'karaf' do

  describe 'On an unsupported OS' do
    let(:facts) { {:osfamily => 'SuSE'} }
    it { should raise_error() }
  end

  context 'on a RedHat OSFamily' do
    # Set the osfamily fact
    let(:facts) { {
        :osfamily => 'RedHat'
      } }

    describe 'with default param values' do
      #
      ## Test default behaviour
      #
      it { should create_class('karaf') }
      it { should contain_class('karaf::params') }
      it { should contain_anchor('karaf::begin') }
      it { should create_class('karaf::java').
        that_requires('Anchor[karaf::begin]').that_comes_before('Class[karaf::install]') }
      it { should create_class('karaf::install').
        that_requires('Class[karaf::java]').that_comes_before('Class[karaf::config]')}
      it { should create_class('karaf::config').
        that_requires('Class[karaf::install]').that_comes_before('Anchor[karaf::end]') }
      it { should create_class('karaf::path').that_requires('Class[karaf::install]') }
      it { should create_class('karaf::service').
        that_requires('Class[karaf::path]').that_comes_before('Anchor[karaf::end]') }
      it { should contain_anchor('karaf::end') }

      # karaf::java resources
      it { should contain_package('java-1.7.0-openjdk').with_ensure('installed') }
      it { should contain_file('/etc/profile.d/java.sh').with({
          'ensure'  => 'present',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => /export JAVA_HOME=\/usr\/lib\/jvm\/jre/
        }).that_requires('Package[java-1.7.0-openjdk]') }

      # karaf::install resources
      it { should contain_anchor('karaf::install::begin') }
      it { should contain_group('karaf').with_ensure('present').that_requires('Anchor[karaf::install::begin]') }
      it { should contain_user('karaf').with_ensure('present').with_gid('karaf').that_requires('Group[karaf]') }
      it { should contain_file('/tmp').that_requires('Anchor[karaf::install::begin]') }
      it { should contain_exec('download_apache-karaf-3.0.1.tar.gz').with( {
          'command' => "wget -q http://mirror.catn.com/pub/apache/karaf/3.0.1/apache-karaf-3.0.1.tar.gz -O /tmp/apache-karaf-3.0.1.tar.gz",
          'creates' => '/tmp/apache-karaf-3.0.1.tar.gz',
          'timeout' => '300'
        } ).that_requires('File[/tmp]') }
      it { should contain_exec('extract-karaf').with( {
          'command' => 'tar zxf /tmp/apache-karaf-3.0.1.tar.gz',
          'cwd'     => '/tmp',
          'creates' => '/opt/apache-karaf-3.0.1'
        } ).that_requires('Exec[download_apache-karaf-3.0.1.tar.gz]') }
      it { should contain_exec('change-ownership').with( {
          'command' => 'chown -R karaf:karaf /tmp/apache-karaf-3.0.1',
          'creates' => '/opt/apache-karaf-3.0.1'
        }).that_requires('Exec[extract-karaf]') }
      it { should contain_exec('move-karaf-3.0.1').with({
          'command' => 'mv /tmp/apache-karaf-3.0.1 /opt/apache-karaf-3.0.1',
          'cwd'     => '/tmp',
          'creates' => '/opt/apache-karaf-3.0.1'
        }).that_requires('Exec[change-ownership]').that_comes_before('Anchor[karaf::install::end]') }
      it { should contain_exec('start-karaf-3.0.1').with({
          'command' => 'sh -c "/opt/apache-karaf-3.0.1/bin/start"',
          'cwd'     => '/opt/apache-karaf-3.0.1',
          'unless'  => ['ps -ef |grep org.apache.karaf|grep -v grep', 'service karaf-service status']
        }).that_requires('Exec[move-karaf-3.0.1]').that_comes_before('Anchor[karaf::install::end]') }
      it { should contain_anchor('karaf::install::end') }

      # karaf::path resources
      it { should contain_file('/etc/profile.d/karaf.sh').with({
          'ensure'  => 'present',
          'owner'   => 'root',
          'group'   => 'root',
          'mode'    => '0644',
          'content' => /\/opt\/apache-karaf-3.0.1\/bin/
        }) }

      # karaf::config resources
      it { should contain_file('/opt/apache-karaf-3.0.1/etc/karaf-wrapper.conf').with({
        'owner' => 'karaf',
        'group' => 'karaf'
      }).with_content(/set.default.JAVA_HOME=\/usr\/lib\/jvm\/jre/).
        that_requires('Exec[install-service]').that_notifies('Service[karaf-service]') }
                
      # karaf::service resource
      it { should contain_karaf_feature('wrapper').with_ensure('present').with_user('karaf') }
      it { should contain_exec('install-service').with({
        'command' => 'client wrapper:install',
        'user'    => 'karaf',
        'path'    => '/opt/apache-karaf-3.0.1/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        'unless'  => 'test -f /opt/apache-karaf-3.0.1/bin/karaf-service'
      }).that_requires('Karaf_feature[wrapper]') }
      it { should contain_file('link-service').with({
        'ensure' => 'link',
        'target' => '/opt/apache-karaf-3.0.1/bin/karaf-service',
        'path'   => '/etc/init.d/karaf-service'
      }).that_requires('Exec[install-service]') }
      it { should contain_exec('stop-karaf').with({
        'command' => 'sh -c "/opt/apache-karaf-3.0.1/bin/stop"',
        'user'    => 'karaf',
        'path'    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
        'onlyif'  => 'ps -ef |grep org.apache.karaf.main.Main|grep -v grep'
      }).that_requires('File[link-service]').that_comes_before('Service[karaf-service]') }
      it { should contain_service('karaf-service').
        with_ensure('running').with_enable('true').that_requires('File[link-service]') }
    end
  end
end