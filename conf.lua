print("Get available APs")
wifi.setmode(wifi.STATION)
wifi.sta.getap(function(t)
   available_aps = ""
   if t then
      for k,v in pairs(t) do
         ap = string.format("%-10s",k)
         ap = trim(ap)
         available_aps = available_aps .. "<option value='".. ap .."'>".. ap .."</option>"
      end
      setup_server(available_aps)
   end
end)

local unescape = function (s)
   s = string.gsub(s, "+", " ")
   s = string.gsub(s, "%%(%x%x)", function (h)
         return string.char(tonumber(h, 16))
      end)
   return s
end

function setup_server(aps)
   print("Setting up Wifi AP")
   wifi.setmode(wifi.SOFTAP)
  cfg = {}
   cfg.ssid = "ESP8266 HOME AUTOMATION";
   cfg.pwd  = "password"
   wifi.ap.config(cfg)     
  wifi.ap.setip({ip="192.168.1.1",netmask="255.255.255.0",gateway="192.168.1.1"})
   print("Setting up webserver")
   srv = nil
   srv=net.createServer(net.TCP)
   srv:listen(80,function(conn)
       conn:on("receive", function(client,request)
           local buf = ""
           local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
           if(method == nil)then
               _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP")
           end
           local _GET = {}
           if (vars ~= nil)then
               for k, v in string.gmatch(vars, "(%w+)=([^%&]+)&*") do
                   _GET[k] = unescape(v)
               end
           end
             
           if (_GET.psw ~= nil and _GET.ap ~= nil and _GET.ipTCP ~= nil) then
              client:send("Saving data..")
              file.open("config.txt", "w+")
                file.writeline(_GET.ap)
                file.writeline(_GET.psw)
            file.writeline(_GET.ipTCP)
            file.writeline(_GET.nmsk)
            file.writeline(_GET.gty)
                 file.close()
                 --node.compile("config.lua")
                 --file.remove("config.lua")
                 client:send(buf)
                node.restart()
           end
   
            buf = "<html><body>"
            buf = buf .. "<br><h3 style = \"color: #fc970e; text-align: center; font-size: 40px; padding: 10px\">Configuration utility</h3>"
            buf = buf .. "<form style = \"border-radius: 20px; border:4px;text-align: center; border-style: solid; padding: 10px; border-color: #4eb0fd\" method='get' action='http://" .. wifi.ap.getip() .."'><br>"
            buf = buf .. "<d style = \"font-family: Arial; font-size: 30px; color: #4eb0fd\">Select access point: </d> <select name='ap'>" .. aps .. "</select><br><br>"          
            buf = buf .. "<d style = \"font-family: Arial; font-size: 30px; color: #4eb0fd\">Enter wifi password: </d> <input style = \" height: 20px; width: 200px; text-align: center;\" type='password' value = 'password' name='psw'></input><br><br>"
            buf = buf .. "<d style = \"font-family: Arial; font-size: 30px; color: #4eb0fd\">Server-IP: </d><input style = \" height: 20px; width: 200px; text-align: center;\" name='ipTCP' value='192.168.1.100'></input><br><br>"
            buf = buf .. "<d style = \"font-family: Arial; font-size: 30px; color: #4eb0fd\">Netmask : </d><input style = \" height: 20px; width: 200px; text-align: center;\" name='nmsk' value='255.255.255.0'></input><br><br>"
            buf = buf .. "<d style = \"font-family: Arial; font-size: 30px; color: #4eb0fd\">Gateway : </d><input style = \" height: 20px; width: 200px; text-align: center;\" name='gty' value='192.168.1.1'></input><br><br>"
            buf = buf .. "<button type='submit' style = \"font-size: 25px; border-color: #1ef59d; border-radius: 20px; background-color: #0dc2ee; color: #fbfcfc\">Save</button>"                   
            buf = buf .. "</form></body></html>"
           client:send(buf)
           client:close()
           collectgarbage()
       end)
   end)
   print("Please connect to: " .. wifi.ap.getip())
end

function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end


