require 'puppet/provider/karaf'

Puppet::Type.type(:karaf_config).provide(:karaf_config, :parent => Puppet::Provider::Karaf) do
  desc "Karaf configuration support."

  def value
    @value
  end
  
  def value=(value)
    args = Array.new
    args << "\""
    args << "config:edit"
    args << @resource[:pid] << ";"
    args << "config:property-set"
    args << @resource[:name] << @resource[:value] << ";"
    args << "config:update"
    args << "\""

    # Run the install command
    karaf_exec(args)
  end
   
  def create
    args = Array.new
    args << "\""
    args << "config:edit"
    args << @resource[:pid] << ";"
    args << "config:property-append"
    args << @resource[:name] << @resource[:value] << ";"
    args << "config:update"
    args << "\""

    # Run the install command
    karaf_exec(args)
  end

  def exists?  
    # Get a list of karaf features
    output = karaf_exec(["'config:list \"(service.pid=#{@resource[:pid]})\"'"])

    # Itterate over
    output.each do |config|
      Puppet.debug("Config = #{config}")

      # Split on '='
      config_info = config.split('=')
      
      # Skip invalid config lines
      next if config_info.length != 2 or config_info[0].strip != @resource[:name]
      
      # Grab value for value
      @value = config_info[1].strip
      return true
    end
    return false
  end
end