require 'spec_helper'

describe Puppet::Type.type(:karaf_feature_repo) do

  before :each do
    described_class.stubs(:defaultprovider).returns providerclass
  end

  let :providerclass do
    described_class.provide(:fake_karaf_feature_repo_provider) { mk_resource_methods }
  end

  it "should have :name as it's namevar" do
    described_class.key_attributes.should == [:name]
  end
  
  describe "when validating attributes" do
    [:name, :version, :host, :port, :karaf_user, :user, :retries].each do |param|
      it "should have a #{param} parameter" do
        described_class.attrtype(param).should == :param
      end
    end
  end
  
  describe "when validating values" do
    describe "for name" do
      it "should support an alphanumerical name" do
        described_class.new(:name => 'feature', :ensure => :present)[:name].should == 'feature'
      end

      it "should support underscores" do
        described_class.new(:name => 'feature_name', :ensure => :present)[:name].should == 'feature_name'
      end
   
      it "should support hyphens" do
        described_class.new(:name => 'feature-name', :ensure => :present)[:name].should == 'feature-name'
      end

      it "should not support spaces" do
        expect { described_class.new(:name => 'feature name', :ensure => :present) }.to raise_error(Puppet::Error, /feature name is not a valid feature repository name/)
      end
    end

    describe "for ensure" do
      it "should support present" do
        described_class.new(:name => 'feature', :ensure => 'present')[:ensure].should == :present
      end

      it "should support absent" do
        described_class.new(:name => 'feature', :ensure => 'absent')[:ensure].should == :absent
      end

      it "should not support other values" do
        expect { described_class.new(:name => 'feature', :ensure => 'foo') }.to raise_error(Puppet::Error, /Invalid value "foo"/)
      end

      it "should not have a default value" do
        described_class.new(:name => 'feature')[:ensure].should == nil
      end
    end
    
    describe "for version" do
      it "should support a value" do
        described_class.new(:name => 'feature', :version => '3.0.0', :ensure => :present)[:version].should == '3.0.0'
      end
    end
    
    #
    ## Common params
    #
    describe "for host" do
      it "should support a value" do
        described_class.new(:name => 'feature', :host => 'hostname', :ensure => :present)[:host].should == 'hostname'
      end
    end
    
    describe "for port" do
      it "should support a numerical value" do
        described_class.new(:name => 'feature', :port => '8000', :ensure => :present)[:port].should == 8000
      end

      it "should have a default value of 4800" do
        described_class.new(:name => 'feature', :ensure => :present)[:port].should == 8101
      end

      it "should not support shorter than 4 digits" do
        expect { described_class.new(:name => 'feature', :port => '123', :ensure => :present) }.to raise_error(Puppet::Error, /123 is not a valid port./)
      end

      it "should not support longer than 5 digits" do
        expect { described_class.new(:name => 'feature', :port => '123456', :ensure => :present) }.to raise_error(Puppet::Error, /123456 is not a valid port./)
      end

      it "should not support a non-numeric value" do
        expect { described_class.new(:name => 'feature', :port => 'a', :ensure => :present) }.to raise_error(Puppet::Error, /a is not a valid port./)
      end
    end
    
    describe "for karaf_user" do
      it "should support an alpha name" do
        described_class.new(:name => 'feature', :karaf_user => 'user', :ensure => :present)[:karaf_user].should == 'user'
      end

      it "should support underscores" do
        described_class.new(:name => 'feature', :karaf_user => 'karaf_user', :ensure => :present)[:karaf_user].should == 'karaf_user'
      end
   
      it "should support hyphens" do
        described_class.new(:name => 'feature', :karaf_user => 'karaf-user', :ensure => :present)[:karaf_user].should == 'karaf-user'
      end

      it "should have a default value of karaf" do
        described_class.new(:name => 'feature', :ensure => :present)[:karaf_user].should == 'karaf'
      end

      it "should not support spaces" do
        expect { described_class.new(:name => 'feature', :karaf_user => 'karaf user', :ensure => :present) }.to raise_error(Puppet::Error, /karaf user is not a valid karaf admin username/)
      end
    end
    
    describe "for user" do
      it "should support an alpha name" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'feature', :user => 'karaf', :ensure => :present)[:user].should == 'karaf'
      end

      it "should support underscores" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'feature', :user => 'karaf_user', :ensure => :present)[:user].should == 'karaf_user'
      end
   
      it "should support hyphens" do
        Puppet.features.expects(:root?).returns(true).once
        described_class.new(:name => 'feature', :user => 'karaf-user', :ensure => :present)[:user].should == 'karaf-user'
      end

      it "should not have a default value of admin" do
        described_class.new(:name => 'feature', :ensure => :present)[:user].should == nil
      end

      it "should not support spaces" do
        Puppet.features.expects(:root?).returns(true).once
        expect { described_class.new(:name => 'feature', :user => 'karaf user') }.to raise_error(Puppet::Error, /karaf user is not a valid user name/)
      end
      
      it "should fail if not running as root" do
        Puppet.features.expects(:root?).returns(false).once
        expect { described_class.new(:name => 'feature', :user => 'karaf') }.to raise_error(Puppet::Error, /Only root can execute commands as other users/)
      end
    end
    
    describe "for port" do
      it "should support a numerical value" do
        described_class.new(:name => 'feature', :retries => '2', :ensure => :present)[:retries].should == 2
      end

      it "should have a default value of 5" do
        described_class.new(:name => 'feature', :ensure => :present)[:retries].should == 5
      end

      it "should not supretries a non-numeric value" do
        expect { described_class.new(:name => 'feature', :retries => 'a', :ensure => :present) }.to raise_error(Puppet::Error, /a is not a valid retries value./)
      end
    end
  end
  
end