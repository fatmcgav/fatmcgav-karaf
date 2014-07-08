require 'puppet/provider/karaf'

Puppet::Type.type(:karaf_kar).provide(:karaf_kar, :parent => Puppet::Provider::Karaf) do
  desc "Karaf kar (Karaf ARchive) support."
  def create
    args = Array.new
    args << "kar:install"
    args << @resource[:location]

    # Run the install command
    karaf_exec(args)
  end

  def destroy
    args = Array.new
    args << "kar:uninstall"
    args << @resource[:name]
  end

  def exists?
    # Get a list of karaf features
    output = karaf_exec(["'kar:list'"])

    # Itterate over
    output.each do |kar|
      Puppet.debug("Kar = #{kar}")

      # Installed?
      return true if kar.strip == @resource[:name]
    end
    return false
  end
end