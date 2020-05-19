# Author: Nate Guagenti (@neu5ron)

def register(params)
  @domain = params["domain"]
end

def filter(event)
  # Get the domain from the event
  domain = event.get(@domain)

  # Perform a few hunts/determinations before cleanup
  # url Contains non whitespace
  domain_has_whitespace = domain.match?(/\s/)
  domain_has_non_ascii = !domain.ascii_only?
  # Regex ends with digit is still faster than performing "Integer(domain[-1]) rescue false" or similar
  domain_ends_with_int = /[0-9]$/ === domain
  # Set things that we always want to add even if it is not a domain. Otherwise certain things like boolean wont make sense when applying filter. otherwise you would have to do _exists_ and then true/false
  domain_is_idn = false

  # Perform general cleanup of the domain name
  #domain = domain.downcase#TODO:renable?
  domain = domain.lstrip.rstrip #this is OK, since we test first
  domain = domain.chomp(".") #TODO: disable? probably not...

  # If domain has no "." then do not perform enrichment
  domain_has_dot = domain.include?(".")
  if domain_has_dot
      # Dont ask.. reverse + chomp + reverse up to 16 times faster
      domain = domain.reverse.chomp(".").reverse

      # Split domain for processing each level
      domain_split = domain.split(".")

      # Begin to set each level specific info
      # If it has a dot then there is a minimum of two levels so set the info for first and second level. Since only using length once for each level do not set as a variable

      # Get the total levels
      domain_total_levels = domain_split.length
      # Get the total length without "."
      domain_total_length = domain.gsub(".", "").length

      # Level 1
      domain_lev1_name = domain_split[-1]

      # Do not perform enrichment on (.arpa) aka IPv4 PTR or IPv6 PTRs.
      if domain_lev1_name != "arpa"
        # Level 1
        #TODO:previous neseted verison #domain_nest = { :"level_1" => { :"name" => domain_lev1_name, :"length" => domain_lev1_name.length } }

  event.set("#{@pid}_orig", pid_orig)
        event.set("#{@domain}_lev1_name", domain_lev1_name)
        event.set("#{@domain}_lev1_length", domain_lev1_name.length)

        # Also, do not perform on domains ending in an integer because as of 2018-06-01 16:02:00 UTC there are no domains that end in an integer currently as of
        if !domain_ends_with_int
            # Level 2
            domain_lev2_name = domain_split[-2]
            #TODO:previous neseted verison #domain_nest.merge! :"level_2" => { :"name" => domain_lev2_name, :"length" => domain_lev2_name.length }
            event.set("#{@domain}_lev2_name", domain_lev2_name)
            event.set("#{@domain}_lev2_length", domain_lev2_name.length)

            # Level 1+2 Name
            domain_1n2_name = domain_lev2_name + "." + domain_lev1_name
            #TODO:previous neseted verison #domain_nest.merge! :"1n2_name" => domain_1n2_name
            event.set("#{@domain}_1n2_name", domain_1n2_name)


            # Set IDN (Internationlized Domain Name)
            if domain.include?("xn--")
              domain_is_idn = true
            end

            if domain_total_levels >= 3
                # Level 3
                domain_lev3_name = domain_split[-3]
                domain_1n2n3_name =  domain_lev3_name + "." + domain_1n2_name
                #TODO:previous neseted verison #domain_nest.merge! :"level_3" => { :"name" => domain_lev3_name, :"length" => domain_lev3_name.length }
                #TODO:previous neseted verison #domain_nest.merge! :"1n2n3_name" => domain_1n2n3_name
                event.set("#{@domain}_lev3_name", domain_lev3_name)
                event.set("#{@domain}_lev3_length", domain_lev3_name.length)
                event.set("#{@domain}_1n2n3_name", domain_1n2n3_name)
                if domain_total_levels - 3 >= 2
                    # Level 4
                    domain_lev4_name = domain_split[-4]
                    #TODO:previous neseted verison #domain_nest.merge! :"level_4" => { :"name" => domain_lev4_name, :"length" => domain_lev4_name.length }
                    event.set("#{@domain}_lev4_name", domain_lev4_name)
                    event.set("#{@domain}_lev4_length", domain_lev4_name.length)
                    # Level 5
                    domain_lev5_name = domain_split[-5]
                    #TODO:previous neseted verison #domain_nest.merge! :"level_5" => { :"name" => domain_lev5_name, :"length" => domain_lev5_name.length }
                    event.set("#{@domain}_lev5_name", domain_lev5_name)
                    event.set("#{@domain}_lev5_length", domain_lev5_name.length)
                elsif domain_total_levels - 3 == 1
                    # Level 4
                    domain_lev4_name = domain_split[-4]
                    #TODO:previous neseted verison #domain_nest.merge! :"level_4" => { :"name" => domain_lev4_name, :"length" => domain_lev4_name.length }
                    event.set("#{@domain}_lev4_name", domain_lev4_name)
                    event.set("#{@domain}_lev4_length", domain_lev4_name.length)
                end
            end
        else
        event.set("#{@domain}_lev_1_name", domain_lev1_name)
        end

      else
        event.set("#{@domain}_lev_1_name", domain_lev1_name)
      end
  end

  # Things to set regardless of other enrichment
  #event.set("[domain][name]", domain)#TODO:reenable?
  event.set("#{@domain}_levs", domain_total_levels)
  event.set("#{@domain}_length", domain_total_length)
  event.set("#{@domain}_ends_with_int", domain_ends_with_int)
  event.set("#{@domain}_has_dot", domain_has_dot)
  event.set("#{@domain}_has_non_ascii", domain_has_non_ascii)
  event.set("#{@domain}_has_whitespace", domain_has_whitespace)
  event.set("#{@domain}_is_idn", domain_is_idn)

  return [event]
end