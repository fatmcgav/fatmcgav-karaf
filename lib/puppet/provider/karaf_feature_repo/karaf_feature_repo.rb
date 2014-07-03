require 'puppet/provider/karaf'

Puppet::Type.type(:karaf_feature_repo).provide(:karaf_feature_repo, :parent => Puppet::Provider::Karaf) do
  desc "Karaf feature repository support."
  
  def create
    args = Array.new
    args << "feature:repo-add"
    args << @resource[:name]
    args << @resource[:version] if @resource[:version]

    # Run the install command
    karaf_exec(args)
  end

  def destroy
    args = Array.new
    args << "feature:repo-remove"
    if @resource[:version] 
      args << "#{@resource[:name]}-#{@resource[:version]}"
    else 
      args << @resource[:name]
    end
      
    # Run the destroy command
    karaf_exec(args)
  end

  def exists?
    # Get a list of karaf feature repos
    output = karaf_exec(["'feature:repo-list'"])

    # Itterate over
    output.each do |feature_repo|
      Puppet.debug("Feature repos = #{feature_repo}")

      # Split into array on '|'
      feature_repo_info = feature_repo.split("|")
      #Puppet.debug("Length = #{feature_repo_info.length}.")
      #Puppet.debug("Contents = #{feature_repo_info.inspect}.")
      #Puppet.debug("Resource[:name] = #{@resource[:name]}.")
      #Puppet.debug("Regex result = #{feature_repo_info[0].strip! =~ /^#{@resource[:name]}/}.")

      # Skip invalid feature lines
      next if feature_repo_info.length != 2

      # Seperate feature repo name and version
      feature_repo_name, feature_repo_version = feature_repo_info[0].strip.split("-")
      Puppet.debug("Feature repo name = #{feature_repo_name}, version = #{feature_repo_version}.")
      
      Puppet.debug("Installed = #{feature_repo_name == @resource[:name] and feature_repo_version == @resource[:version]}")
      
      # Installed?
      return true if feature_repo_name == @resource[:name] and feature_repo_version == @resource[:version] 
    end
    Puppet.debug("No matching resource found.")
    return false
  end
end