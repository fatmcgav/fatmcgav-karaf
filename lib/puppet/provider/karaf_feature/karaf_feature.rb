require 'puppet/provider/karaf'
Puppet::Type.type(:karaf_feature).provide(:karaf_feature, :parent => Puppet::Provider::Karaf) do
  desc "Karaf feature support."
  
  # This creates a bunch of getters/setters for our properties/parameters
  # this is only for prefetch/flush providers
  mk_resource_methods
  
  def create
    args = Array.new
    args << "feature:install"
    args << @resource[:name]
      
    # Run the install command
    karaf_exec(args)
  end

  def exists? 
    # Get a list of karaf features
    output = karaf_exec(["feature:list"])
    
    # Itterate over
    output.each do |feature|
      Puppet.debug("Feature = #{feature}")
      feature_info = feature.split("|")
      
      next if feature_info.length != 5 or feature_info[0].strip != @resource[:name]
        
      return true if feature_info[2].strip == "x"
    end
    return false
  end  
end