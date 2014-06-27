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
      it { should create_class('karaf::install').that_requires('Anchor[karaf::begin]')}
      it { should create_class('karaf::path').that_requires('Class[karaf::install]') }
      
      it { should contain_anchor('karaf::end') }
        
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
      it { should contain_anchor('karaf::install::end') }
      
      # karaf::path resources
      it { should contain_file('/etc/profile.d/karaf.sh').with({ 
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => 'root',
        'mode'    => '0644',
        'content' => /\/opt\/apache-karaf-3.0.1\/bin/
      }) }
    end
  end 
end