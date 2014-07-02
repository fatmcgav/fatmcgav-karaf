require 'puppet/provider/karaf'

Puppet::Type.type(:karaf_feature).provide(:karaf_feature, :parent => Puppet::Provider::Karaf) do
  desc "Karaf feature support."
  def create
    args = Array.new
    args << "feature:install"
    args << @resource[:name]

    # Run the install command
    karaf_exec(args)
  end

  def destroy
    args = Array.new
    args << "feature:uninstall"
    args << @resource[:name]
  end

  def exists?
    # Get a list of karaf features
    output = karaf_exec(["'feature:list --installed'"])

    # Itterate over
    output.each do |feature|
      Puppet.debug("Feature = #{feature}")

      # Split into array on '|'
      feature_info = feature.split("|")

      # Skip invalid feature lines
      next if feature_info.length != 5 or feature_info[0].strip != @resource[:name]

      # Installed?
      return true if feature_info[2].strip == "x"
    end
    return false
  end
end