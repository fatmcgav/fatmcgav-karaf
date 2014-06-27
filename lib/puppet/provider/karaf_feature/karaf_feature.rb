require 'puppet/provider/karaf'
Puppet::Type.type(:karaf_feature).provide(:karaf_feature, :parent => Puppet::Provider::Karaf) do
  desc "Karaf feature support."

  attr_accessor :karaf_exec
  
  # This creates a bunch of getters/setters for our properties/parameters
  # this is only for prefetch/flush providers
  mk_resource_methods
  
  def self.instances
    Puppet.debug("Puppet::Provider::Karaf: Got to self.instances")
    # Create a new array to hold our features
    features = Array.new
    
    # Get a list of karaf features
    output = karaf_exec("feature:list")
    
    # Itterate over
    output.each do |feature|
      Puppet.debug("Feature = #{feature}")
      feature_info = feature.split("|")
      
      # Skip any rows that aren't valid features
      Puppet.debug("Feature_info array has #{feature_info.length} entries.")
      next if feature_info.length != 5 or feature_info[0].strip == 'Name'
      Puppet.debug("Got a valid feature - #{feature_info.inspect}")
   
      # Process valid feature      
      feature_name = feature_info[0].strip!
      feature_version = feature_info[1].strip!
      feature_installed = feature_info[2].strip!
      feature_repository = feature_info[3].strip!
      Puppet.debug("Feature_name = #{feature_name}, feature_version = #{feature_version}, feature_installed = #{feature_installed}.")
      
      # Start to build resource hash
      feature_hash = { :name       => feature_name, 
                       :version    => feature_version,
                       :repository => feature_repository}
      
      # Set ensure status
      feature_hash[:ensure] = (feature_installed == 'x' && :present) || :absent
      
      # Create the instance and add to features array
      Puppet.debug("Feature_hash = #{feature_hash.inspect}")
      features << new(feature_hash)
    end
    
    # Return the full features array
    Puppet.debug("Features looks like: \n #{features.inspect}")
    features
  end
  
  def self.prefetch(resources)
    Puppet.debug("Puppet::Provider::Karaf: Got to self.prefetch.")
    # Iterate instances and match provider where relevant.
    instances.each do |prov|
      Puppet.debug("Prov.name = #{resources[prov.name]}. ")
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end
  
  def create
    args = Array.new
    args << "feature:install"
    args << @resource[:name]
      
    # Run the install command
    karaf_exec(args)
  end
  
  def exists?
    @property_hash[:ensure] == :present
  end

end