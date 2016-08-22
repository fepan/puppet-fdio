Puppet::Type.newtype(:vpp_interface_cfg) do
  newparam(:name) do
  end

  newparam(:interfaces, :array_matching => :all) do
    desc "VPP Interfaces or pci dev addresses"
    munge do |values|
      values = [values] unless values.is_a?(Array)
      values.map! do |value|
        if value =~ /\p{XDigit}+:(\p{XDigit}+):(\p{XDigit}+)\.(\p{XDigit}+)/
          "%d/%d/%d" % ["0x#{$1}".hex, "0x#{$2}".hex, "0x#{$3}".hex]
        else
          value
        end
      end
    end
  end

  newproperty(:state) do
    newvalue(:up)
    newvalue(:down)
  end

  newproperty(:ipaddress, :array_matching => :all) do
    validate do |values|
      values = [values] unless values.is_a?(Array)
    end
  end

end
