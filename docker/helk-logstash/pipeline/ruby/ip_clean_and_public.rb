# Author: Nate Guagenti (@neu5ron)
require "set"
require "ipaddr"
IPv6Privatecidr = [ "fc00::/7", "fe80::/10", "ff00::/8", "2001:db8::/32", "2001:20::/28", "::1/128", "::/128", "100::/64", "64:ff9b::/96" ]


def register(params)
  @parent_field = params["parent_field"]
  @orig_ip_address = params["ip"]
  @orig_is_ipv6 = params["is_ipv6"]
end

def filter(event)
  ip_addresses = event.get(@orig_ip_address)

  # Check if IPv6 determination is already made
  ip_addresses_is_ipv6 = event.get(@orig_is_ipv6)
  if ip_addresses_is_ipv6.nil?
    ip_addresses_is_ipv6 = Array.new
  else
    ip_addresses_is_ipv6 = [ ip_addresses_is_ipv6 ]
  end

  ip_addresses_public = Array.new
  ip_addresses_type = Array.new
  ip_addresses_rfc = Array.new
  not_ip_addresses = Array.new
  version_ip_addresses = Array.new
  clean_ip_addresses = Array.new

  # Determine if the IP field is an array if not make it an array for continuity
  if ip_addresses.is_a? Enumerable
    ip_addresses = ip_addresses.uniq
  else
    ip_addresses = [ ip_addresses ]
  end

  for ip_address in ip_addresses
    #### General Cleanup
    # Remove quoted
    ip_address = ip_address.delete("'")
    ip_address = ip_address.delete("\"")
    # Remove ending "."
    ip_address = ip_address.chomp
    # Remove preceding "."# Don't ask.. reverse + chomp + reverse up to 16 times faster
    ip_address = ip_address.reverse.chomp(".").reverse
    # Remove ending or beginning whitespace
    ip_address = ip_address.lstrip.rstrip
    # Remove things that would make an IP a share but we want the IP :)
    ip_address = ip_address.gsub(/^\\:?/, "")
    # Downcase/lowercase for checking if possible ipv6
    ip_address = ip_address.downcase

    # IPv4
    ip_address_length = ip_address.length
    if !ip_address.include?(":") && !( /[a-z]/ === ip_address ) && ip_address_length <= 15 && ip_address_length >= 7
      # Remove any preceding zeroes in each octet
      temp_ip = Array.new
      ip_address.split(".").each do |octet|
          octet = octet.to_i.to_s
          temp_ip.push(octet)
      end
      ip_address = temp_ip.join('.')

      begin
        IPAddr.new(ip_address)
        # ip_address = IPAddr.new(ip_address)
        # IP Version 4 (ipv4)

        # Private/RFC1918
        if ip_address.start_with?( "10.", "192.168." )
            ip_public = "false"
            ip_type = "private"
            ip_rfc = "RFC_1918"

        # (Local)link-local RFC3927
        elsif ip_address.start_with?( "169.254." )
            ip_public = "false"
            ip_type = "local"
            ip_rfc = "RFC_3927"

        # Loopback RFC1122-3.2.1.3
        elsif ip_address.start_with?( "127." )
            ip_public = "false"
            ip_type = "loopback"
            ip_rfc = "RFC_1122-3.2.1.3"

        # RFC1700
        elsif ip_address.start_with?("0.")
            ip_public = "false"
            ip_type = "reserved_as_a_source_address_only"
            ip_rfc = "RFC_1700"

        # IPv6 to IP4 anycast RFC3068
        elsif ip_address.start_with?( "192.88.99." )
            ip_public = "false"
            ip_type = "6to4"
            ip_rfc = "RFC_3068"

        # IPv6 to IP4 anycast RFC7535
        elsif ip_address.start_with?( "192.31.196." )
            ip_public = "false"
            ip_type = "as112-v4"
            ip_rfc = "RFC_3068"

        # IPv6 to IP4 anycast RFC7450, "Automatic Multicast Tunneling"
        elsif ip_address.start_with?( "192.52.193" )
            ip_public = "false"
            ip_type = "amt"
            ip_rfc = "RFC_7450"

        #  Reserved RFC6890, RFC1122-3.2.1.3, RFC2544, RFC5737
        elsif ip_address.start_with?( "0.", "192.0.0.", "192.0.1.", "192.0.2.", "192.18.", "192.19.", "198.51.100.", "203.0.113." )
            ip_public = "false"
            ip_type = "reserved"
            ip_rfc = [ "RFCRFC_19186890", "RFCRFC_19181122-3.2.1.3", "RFCRFC_19182544", "RFCRFC_19185737" ]

        # Private/RFC-1918 -- continued -- 172.16.0.0-17.31.255.255
        elsif ip_address.start_with?( "172." )
            # Check if 2nd octet is in range(between) 16 to 31
            if ip_address.split(".")[1].to_i.between?(16,31)
                ip_public = "false"
                ip_type = "private"
                ip_rfc = "RFC_1918"
            else
              ip_public = "true"
              ip_type = "public"
              ip_rfc = "RFC_1366"
            end

        # Private/RFC-1918 -- continued -- 100.64.0.1 - 100.127.255.254
        elsif ip_address.start_with?( "100." )
            # Check if 2nd octet is in range(between) 64 to 127
            if ip_address.split(".")[1].to_i.between?(64,127)
                ip_public = "false"
                ip_type = "private"
                ip_rfc = "RFC_1918"
            else
              ip_public = "true"
              ip_type = "public"
              ip_rfc = "RFC_1366"
            end

        # The remaining possible NON public/routable IPs begin with 2 and are either multicast or broadcast
        elsif ip_address.start_with?( "2" )
            # Broadcast
            if ip_address == "255.255.255.255"
                ip_public = "false"
                ip_type = "broadcast"
                ip_rfc = "RFC_8190"

            # Multicast
            # Check if 1st octet is in range(between) 224 to 255
            elsif ip_address.split(".")[0].to_i.between?(224,255)
                ip_public = "false"
                ip_type = "multicast"
                ip_rfc = "RFC_1112"
            else
              ip_public = "true"
              ip_type = "public"
              ip_rfc = "RFC_1366"
            end

        # RFC1366, Public/Routable
          else
            ip_public = "true"
            ip_type = "public"
            ip_rfc = "RFC_1366"
        end
        # set parameters
        clean_ip_addresses.push(ip_address)
        version_ip_addresses.push("4")
        ip_addresses_is_ipv6.push("false")
        ip_addresses_public.push(ip_public)
        ip_addresses_type.push(ip_type)
        ip_addresses_rfc.push(ip_rfc)
      rescue
        not_ip_addresses.push(ip_address)
      end

    # IPv6
    elsif ip_address_length <= 39 && ip_address_length >= 2 && ip_address.ascii_only?
      begin
        ip_address_check = IPAddr.new(ip_address)
        # Public IP Check
        ip_public = "true"
        temp_ip_check = "zDamTyILGeKD4H0.IbPK6g"
        IPv6Privatecidr.each do |i_p|
          cidr = IPAddr.new(i_p)
          if cidr.include?(ip_address_check)
            ip_public = "false"
          end
        end
        # set parameters
        #TODO:eventually set to real type(rfc description) and real rfc (rfc code)
        if ip_address == "::1"
          ip_type = "loopback"
          ip_rfc = "RFC_4291"
        else
          ip_type = "n/a"
          ip_rfc = "n/a"
        end
        clean_ip_addresses.push(ip_address)
        version_ip_addresses.push("6")
        ip_addresses_is_ipv6.push("true")
        ip_addresses_public.push(ip_public)
        ip_addresses_type.push(ip_type)
        ip_addresses_rfc.push(ip_rfc)
      rescue
        not_ip_addresses.push(ip_address)
      end
    else
      not_ip_addresses.push(ip_address)
    end
  end



  number_of_ip_addresses = clean_ip_addresses.length
  # Set the clean IP(s) and new parameters...
  if !clean_ip_addresses.empty?
    # Set the number of ip addresses so we can use array or non array later in pipeline and this script.....##zDamTyILGeKD4H0##
    event.set("[@metadata][#{@orig_ip_address}][number_of_ip_addresses]", number_of_ip_addresses)
    # Use to make array versus non array
    if number_of_ip_addresses == 1
      event.set("#{@parent_field}_ip_version", version_ip_addresses[0])
      event.set("#{@parent_field}_is_ipv6", ip_addresses_is_ipv6[0])
      event.set("#{@parent_field}_ip_public", ip_addresses_public[0])
      event.set("#{@parent_field}_ip_type", ip_addresses_type[0])
      event.set("#{@parent_field}_ip_rfc", ip_addresses_rfc[0])
      event.remove("#{@orig_ip_address}")
      event.set("#{@orig_ip_address}", clean_ip_addresses[0])

    else
      event.set("#{@parent_field}_ip_version", version_ip_addresses)
      event.set("#{@parent_field}_is_ipv6", ip_addresses_is_ipv6)
      event.set("#{@parent_field}_ip_public", ip_addresses_public)
      event.set("#{@parent_field}_ip_type", ip_addresses_type)
      event.set("#{@parent_field}_ip_rfc", ip_addresses_rfc)
      event.remove("#{@orig_ip_address}")
      event.set("#{@orig_ip_address}", clean_ip_addresses)
    end
  else
    event.remove("#{@orig_ip_address}")
  end
  # Set non clean IP(s)
  if !not_ip_addresses.empty?
    event.tag("Invalid IP(s) #{not_ip_addresses}")
    event.set("not_ip_#{@parent_field}", not_ip_addresses)
  end

  return [event]
end
