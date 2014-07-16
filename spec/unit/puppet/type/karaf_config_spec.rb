require 'spec_helper'

describe Puppet::Type.type(:karaf_config) do

  before :each do
    described_class.stubs(:defaultprovider).returns providerclass
  end

  let :providerclass do
    described_class.provide(:fake_karaf_config_provider) { mk_resource_methods }
  end

  it "should have :name as it's namevar" do
    described_class.key_attributes.should == [:name]
  end
  
  describe "when validating attributes" do
    [:name, :pid, :host, :port, :karaf_user, :user, :retries, :delay].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
    
    [:ensure, :value].each do |property|
      it "should have a #{property} property" do
        described_class.attrtype(property).should == :property
      end
    end
  end
  
  describe "when validating values" do
    describe "for name" do
      it "should support an alphanumerical name" do
        described_class.new(:name => 'config', :ensure => :present)[:name].should == 'config'
      end

      it "should support underscores" do
        described_class.new(:name => 'config_name', :ensure => :present)[:name].should == 'config_name'
      end
   
      it "should support hyphens" do
        described_class.new(:name => 'config-name', :ensure => :present)[:name].should == 'config-name'
      end
      
      it "should support periods" do
        described_class.new(:name => 'config.name', :ensure => :present)[:name].should == 'config.name'
      end

      it "should not support spaces" do
        expect { described_class.new(:name => 'config name', :ensure => :present) }.to raise_error(Puppet::Error, /config name is not a valid config property name/)
      end
    end

    describe "for ensure" do
      it "should support present" do
        described_class.new(:name => 'config', :ensure => 'present')[:ensure].should == :present
      end

      it "should support absent" do
        described_class.new(:name => 'config', :ensure => 'absent')[:ensure].should == :absent
      end

      it "should not support other values" do
        expect { described_class.new(:name => 'config', :ensure => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end

      it "should not have a default value" do
        described_class.new(:name => 'config')[:ensure].should == nil
      end
    end
    
    describe "for location" do
      it "should support an dotted name" do
        described_class.new(:name => 'config', :pid => 'org.apache.karaf.shell', :ensure => :present)[:pid].should == 'org.apache.karaf.shell'
      end

      it "should not support spaces" do
        expect { described_class.new(:name => 'config', :pid => 'org.apache.karaf shell', :ensure => :present) }.to raise_error(Puppet::Error, /org.apache.karaf shell is not a valid service pid/)
      end
    end
    
    describe "for value" do
      it "should support a value" do
        described_class.new(:name => 'config', :value => 'value', :ensure => :present)[:value].should == 'value'
      end
    end
    
    #
    ## Common params
    #
    describe "for host" do
      it "should support a value" do
        described_class.new(:name => 'kar', :host => 'hostname', :ensure => :present)[:host].should == 'hostname'
      end
    end
    
    describe "for port" do
      it "should support a numerical value" do
        described_class.new(:name => 'kar', :port => '8000', :ensure => :present)[:port].should == 8000
      end

      it "should have a default value of 4800" do
        described_class.new(:name => 'kar', :ensure => :present)[:port].should == 8101
      end

      it "should not support shorter than 4 digits" do
        expect { described_class.new(:name => 'kar', :port => '123', :ensure => :present) }.to raise_error(Puppet::Error, /123 is not a valid port./)
      end

      it "should not support longer than 5 digits" do
        expect { described_class.new(:name => 'kar', :port => '123456', :ensure => :present) }.to raise_error(Puppet::Error, /123456 is not a valid port./)
      end

      it "should not support a non-numeric value" do
        expect { described_class.new(:name => 'kar', :port => 'a', :ensure => :present) }.to raise_error(Puppet::Error, /a is not a valid port./)
      end
    end
    
    describe "for karaf_user" do
      it "should support an alpha name" do
        described_class.new(:name => 'kar', :karaf_user => 'user', :ensure => :present)[:karaf_user].should == 'user'
      end

      it "should support underscores" do
        described_class.new(:name => 'kar', :karaf_user => 'karaf_user', :ensure => :present)[:karaf_user].should == 'karaf_user'
      end
   
      it "should support hyphens" do
        described_class.new(:name => 'kar', :karaf_user => 'karaf-user', :ensure => :present)[:karaf_user].should == 'karaf-user'
      end

      it "should have a default value of karaf" do
        described_class.new(:name => 'kar', :ensure => :present)[:karaf_user].should == 'karaf'
      end

      it "should not support spaces" do
        expect { described_class.new(:name => 'kar', :karaf_user => 'karaf user', :ensure => :present) }.to raise_error(Puppet::Error, /karaf user is not a valid karaf admin username/)
      end
    end
    
    describe "for user" do
      it "should support an alpha name" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'kar', :user => 'karaf', :ensure => :present)[:user].should == 'karaf'
      end

      it "should support underscores" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'kar', :user => 'karaf_user', :ensure => :present)[:user].should == 'karaf_user'
      end
   
      it "should support hyphens" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'kar', :user => 'karaf-user', :ensure => :present)[:user].should == 'karaf-user'
      end

      it "should not have a default value of admin" do
        described_class.new(:name => 'kar', :ensure => :present)[:user].should == nil
      end

      it "should not support spaces" do
        Puppet.features.expects(:root?).returns(true).once
        expect { described_class.new(:name => 'kar', :user => 'karaf user') }.to raise_error(Puppet::Error, /karaf user is not a valid user name/)
      end
      
      it "should fail if not running as root" do
        Puppet.features.expects(:root?).returns(false).once
        expect { described_class.new(:name => 'kar', :user => 'karaf') }.to raise_error(Puppet::Error, /Only root can execute commands as other users/)
      end
    end
    
    describe "for retries" do
      it "should support a numerical value" do
        described_class.new(:name => 'kar', :retries => '2', :ensure => :present)[:retries].should == 2
      end

      it "should have a default value of 5" do
        described_class.new(:name => 'kar', :ensure => :present)[:retries].should == 5
      end

      it "should not support a non-numeric value" do
        expect { described_class.new(:name => 'kar', :retries => 'a', :ensure => :present) }.to raise_error(Puppet::Error, /a is not a valid retries value./)
      end
    end
    
    describe "for delay" do
      it "should support a numerical value" do
        described_class.new(:name => 'kar', :delay => '2', :ensure => :present)[:delay].should == 2
      end

      it "should have a default value of 5" do
        described_class.new(:name => 'kar', :ensure => :present)[:delay].should == 5
      end

      it "should not support a non-numeric value" do
        expect { described_class.new(:name => 'kar', :delay => 'a', :ensure => :present) }.to raise_error(Puppet::Error, /a is not a valid retry delay value./)
      end
    end
  end
  
end