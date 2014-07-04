Puppet::Type.newtype(:karaf_feature_repo) do
  @doc = "Manage Karaf feature repositories"
  
  ensurable
  
  newparam(:name) do
    desc "Karaf feature repository name/URL"
    isnamevar
    
    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid feature repository name." % value
      end
    end
  end
  
  newparam(:version) do
    desc "Karaf feature repository vesion"
  end
  
  #
  ## Common params
  #
  newparam(:host) do 
    desc "Karaf host"
  end
  
  newparam(:port) do
    desc "Karaf admin port"
    defaultto '8101'

    validate do |value|
      raise ArgumentError, "%s is not a valid port." % value unless value =~ /^\d{4,5}$/
    end

    munge do |value|
      case value
      when String
        if value =~ /^[-0-9]+$/
          value = Integer(value)
        end
      end

      return value
    end
  end
  
  newparam(:karaf_user) do
    desc "Karaf admin username"
    defaultto 'karaf'

    validate do |value|
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid karaf admin username." % value
      end
    end
  end
  
  newparam(:user) do
    desc "Linux user to run command as"

    validate do |value|
      unless Puppet.features.root?
        self.fail "Only root can execute commands as other users"
      end
      unless value =~ /^[\w-]+$/
         raise ArgumentError, "%s is not a valid user name." % value
      end
    end
  end
  
  newparam(:retries) do
    desc "Number of times to retry command"
    defaultto '5'
    
    validate do |value|
      raise ArgumentError, "%s is not a valid retries value." % value unless value =~ /^\d+$/
    end

    munge do |value|
      case value
      when String
        if value =~ /^[-0-9]+$/
          value = Integer(value)
        end
      end

      return value
    end
  end
  
end