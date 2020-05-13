# Author: Nate Guagenti (@neu5ron)

def register(params)
  @pid = params["pid"]
end

def filter(event)

  # Copy original value before modifying
  pid_orig = pid

  if !pid.nil? && !pid.empty?
    if pid.to_s.start_with?( "0x" )
      pid = pid.gsub(/^0x/,"").to_s.hex
    end
  end

  event.set("#{@pid}_orig", pid_orig)
  event.set("#{@pid}", pid)

  return [event]
end
