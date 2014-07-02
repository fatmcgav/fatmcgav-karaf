class Puppet::Provider::Karaf < Puppet::Provider
  
  Puppet.debug("Loaded Puppet::Provider::Karaf")
  def karaf_exec(passed_args)
    Puppet.debug("Got to Puppet::Provider::Karaf::karaf_exec")

    #Puppet.debug("@resource.parameters == #{@resource.parameters.inspect}.")
    
    # Compile an array of command args
    args = Array.new
    args << '-h' << @resource[:host] if @resource[:host] && !@resource[:host].nil?
    args << '-a' << @resource[:port] if @resource[:port] && !@resource[:port].nil?
    args << '-u' << @resource[:karaf_user] if @resource && !@resource[:karaf_user].empty?

    # Need to add the passed_args to args array.
    passed_args.each { |arg| args << arg }

    # Transform args array into a exec args string.
    exec_args = args.join " "
    command = "client #{exec_args}"
    Puppet.debug("client command = #{command}")

    # Compile the actual command as the specified user.
    command = "su - #{@resource[:user]} -c \"#{command}\"" if @resource && !@resource[:user].empty?
    # Debug output of command if required.
    Puppet.debug("exec command = #{command}")

    # Execute the command.
    output = `#{command}`
    # Check return code and fail if required
    self.fail output unless $? == 0

    # Split into array, for later processing...
    result = output.split(/\n/)
    Puppet.debug("result = \n#{result.inspect}")

    # Return the result
    result
  end
  
end