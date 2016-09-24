Puppet::Type.type(:vpp_interface_cfg).provide :vpp do
  
  def get_int_prefix(name)
    if %r{([[:alpha:]]*#{name})\s+} =~ `vppctl show int`
      return $1
    else
      raise "Cannot find vpp interface matching: %s" % name
    end
  end

  def state
    @resource[:interfaces].each do |interface|
      vpp_int_output = `vppctl show int #{get_int_prefix(interface)}`
      if ! /\s+up\s+/.match(vpp_int_output)
        return "down"
      end
    end
    return "up"
  end

  def state=(value)
    @resource[:interfaces].each do |interface|
      if ! system("vppctl set int state #{get_int_prefix(interface)} #{value}")
        raise "Failed to configure interface state for %s" % interface
      end
    end
  end

  def ipaddress
    ip_list = []
    @resource[:interfaces].each do |interface|
      vpp_int_output = `vppctl show int address #{get_int_prefix(interface)}`
      if vpp_int_output =~ /(\d+\.\d+.\d+.\d+\/\d+)/
        ip_list.push($1)
      else
        ip_list.push("None")
      end
    end

    return ip_list
  end

  def ipaddress=(values)
    if @resource[:interfaces].size != @resource[:ipaddress].size
    	fail "different numbers of ip addresses and interfaces supplied"
    end
    @resource[:interfaces].zip(@resource[:ipaddress]).each do |interface, ip|
      if ! system("vppctl set int ip address #{get_int_prefix(interface)} #{ip}")
        raise "Failed to configure ip %s for interface %s" % [$ip, $interface]
      end
    end
  end
end

