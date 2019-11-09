# Author: Derek Ditch (@dcode), Nate Guagenti (@neu5ron)
require 'socket'
require 'digest'
require 'base64'

TRANSPORT_PROTOS = ['icmp', 'icmp6', 'tcp', 'udp', 'sctp']

PROTO_MAP = {
  'icmp' => 1,
  'tcp' => 6,
  'udp' => 17,
  'icmp6' => 58
}

ICMP4_MAP = {
  # Echo => Reply
  8 => 0,
  # Reply => Echo
  0 => 8,
  # Timestamp => TS reply
  13 => 14,
  # TS reply => timestamp
  14 => 13,
  # Info request => Info Reply
  15 => 16,
  # Info Reply => Info Req
  16 => 15,
  # Rtr solicitation => Rtr Adverstisement
  10 => 9,
  # Mask => Mask reply
  17 => 18,
  # Mask reply => Mask
  18 => 17,
}

ICMP6_MAP = {
  # Echo Request => Reply
  128 => 129,
  # Echo Reply => Request
  129 => 128,
  # Router Solicit => Advert
  133 => 134,
  # Router Advert => Solicit
  134 => 133,
  # Neighbor Solicit => Advert
  135 => 136,
  # Neighbor Advert => Solicit
  136 => 135,
  # Multicast Listener Query => Report
  130 => 131,
  # Multicast Report => Listener Query
  131 => 130,
  # Node Information Query => Response
  139 => 140,
  # Node Information Response => Query
  140 => 139,
  # Home Agent Address Discovery Request => Reply
  144 => 145,
  # Home Agent Address Discovery Reply => Request
  145 => 144,
}

VERSION = '1:'

def bin_to_hex(s)
  s.each_byte.map { |b| b.to_s(16).rjust(2, '0') }.join(':')
end

def register(params)
  @use_base64 = params.fetch("use_base64", "true")
  @comm_id_seed = params.fetch("community_id_seed", "0").to_i
  @target_field = params["target_field"]
  @source_ip = params["source_ip_field"]
  @source_port = params["source_port_field"]
  @dest_ip = params["dest_ip_field"]
  @dest_port = params["dest_port_field"]
  @protocol = params["protocol_field"]
end

def filter(event)

  if @target_field.nil?
    event.tag("community_id_target_field_not_set")
    return [event]
  end

  # Tag and quit if any fields aren't present
  [@source_ip, @source_port, @dest_ip, @dest_port, @protocol].each do |field|
    if event.get(field).nil?
      event.tag("#{field}_not_found")
      return [event]
    end
  end

  # Retrieve the fields
  src_ip = event.get("#{@source_ip}")
  src_p = event.get("#{@source_port}").to_i
  dst_ip = event.get("#{@dest_ip}")
  dst_p = event.get("#{@dest_port}").to_i
  protocol = event.get("#{@protocol}")

  # Parse to sockaddr_in struct bytestring
  src = Socket.sockaddr_in(src_p, src_ip)
  dst = Socket.sockaddr_in(dst_p, dst_ip)

  is_one_way = false
  # Special case handling for ICMP type/codes
  if protocol == 'icmp' || protocol == 'icmp6'
    if src.length == 16 # IPv4
      if ICMP4_MAP.has_key?(src_p) == false
        is_one_way = true
      end
    elsif src.length == 28 # IPv6
      if ICMP6_MAP.has_key?(src_p) == false
        is_one_way = true
      end
      # Set this correctly if not already set
      protocol = 'icmp6'
    end
  end

  # Fetch the protocol number
  proto = PROTO_MAP.fetch(protocol.downcase, 0)

  # Parse out the network-ordered bytestrings for ip/ports....####zDamTyILGeKD4H0####
  if src.length == 16 # IPv4
    sip = src[4,4]
    sport = src[2,2]
  elsif src.length == 28 # IPv6
    sip = src[4,16]
    sport = src[2,2]
  end
  if dst.length == 16 # IPv4
    dip = dst[4,4]
    dport = dst[2,2]
  elsif dst.length == 28 # IPv6
    dip = dst[4,16]
    dport = dst[2,2]
  end

  if !( is_one_way || ((sip <=> dip) == -1) || ((sip == dip) && ((sport <=> dport) < 1)) )
    mip = sip
    mport = sport
    sip = dip
    sport = dport
    dip = mip
    dport = mport
  end

  # Hash all the things
  hash = Digest::SHA1.new
  hash.update([@comm_id_seed].pack('n')) # 2-byte seed

  hash.update(sip)  # 4 bytes (v4 addr) or 16 bytes (v6 addr)
  hash.update(dip)  # 4 bytes (v4 addr) or 16 bytes (v6 addr)####IbPK6g####

  hash.update([proto].pack('C')) # 1 byte for transport proto
  hash.update([0].pack('C')) # 1 byte padding

  # If transport protocol, hash the ports too
  hash.update(sport) # 2 bytes for port
  hash.update(dport) # 2 bytes for port

  comm_id = nil

  if @use_base64
      comm_id = VERSION + Base64.strict_encode64(hash.digest)
  else
      comm_id = VERSION + hash.hexdigest
  end


  event.set("#{@target_field}", comm_id)

  return [event]
end

### Validation Tests

test "when proto is tcpv4" do
  parameters {{"source_ip_field" => "src_ip", "dest_ip_field" => "dst_ip", "source_port_field" => "src_port", "dest_port_field" => "dst_port", "protocol_field" => "protocol", "target_field" => "community_id" }}
  in_event {{ "dst_ip" => "66.35.250.204", "src_ip" => "128.232.110.120", "dst_port" => 80, "src_port" => 34855, "protocol" => "tcp" }}
  expect("the hash is computed") {|events| events.first.get("community_id") == "1:LQU9qZlK+B5F3KDmev6m5PMibrg=" }
end

test "when proto is udpv4" do
  parameters {{"source_ip_field" => "src_ip", "dest_ip_field" => "dst_ip", "source_port_field" => "src_port", "dest_port_field" => "dst_port", "protocol_field" => "protocol", "target_field" => "community_id" }}
  in_event {{ "dst_ip" => "8.8.8.8", "src_ip" => "192.168.1.52", "dst_port" => 53, "src_port" => 54585, "protocol" => "udp" }}
  expect("the hash is computed") {|events| events.first.get("community_id") == "1:d/FP5EW3wiY1vCndhwleRRKHowQ=" }
end

test "when proto is IPv6" do
  parameters {{"source_ip_field" => "src_ip", "dest_ip_field" => "dst_ip", "source_port_field" => "src_port", "dest_port_field" => "dst_port", "protocol_field" => "protocol", "target_field" => "community_id" }}
  in_event {{ "dst_ip" => "2607:f8b0:400c:c03::1a", "src_ip" => "2001:470:e5bf:dead:4957:2174:e82c:4887", "dst_port" => 25, "src_port" => 63943, "protocol" => "tcp" }}
  expect("the hash is computed") {|events| events.first.get("community_id") == "1:/qFaeAR+gFe1KYjMzVDsMv+wgU4=" }
end

test "when proto is icmpv4" do
  parameters {{"source_ip_field" => "src_ip", "dest_ip_field" => "dst_ip", "source_port_field" => "src_port", "dest_port_field" => "dst_port", "protocol_field" => "protocol", "target_field" => "community_id" }}
  in_event {{ "dst_ip" => "192.168.0.1", "src_ip" => "192.168.0.89", "dst_port" => 0, "src_port" => 8, "protocol" => "icmp" }}
  expect("the hash is computed") {|events| events.first.get("community_id") == "1:X0snYXpgwiv9TZtqg64sgzUn6Dk=" }
end

test "when proto is icmpv6" do
  parameters {{"source_ip_field" => "src_ip", "dest_ip_field" => "dst_ip", "source_port_field" => "src_port", "dest_port_field" => "dst_port", "protocol_field" => "protocol", "target_field" => "community_id" }}
  in_event {{ "dst_ip" => "3ffe:507:0:1:200:86ff:fe05:80da", "src_ip" => "3ffe:501:0:1802:260:97ff:feb6:7ff0", "dst_port" => 0, "src_port" => 3, "protocol" => "icmp" }}
  expect("the hash is computed") {|events| events.first.get("community_id") == "1:bnQKq8A2r//dWnkRW2EYcMhShjc=" }
end

test "when field doesn't exist" do
  parameters { {"source_ip_field" => "src_ip", "dest_ip_field" => "dst_ip", "source_port_field" => "src_port", "dest_port_field" => "dst_port", "protocol_field" => "protocol", "target_field" => "community_id" } }
  in_event {{ "dst_ip" => "8.8.8.8", "source_ip" => "192.168.1.52", "dst_port" => 53, "src_port" => 54585, "protocol" => "udp" }}
  expect("tags as not found") {|events| events.first.get("tags").include?("src_ip_not_found") }
end
