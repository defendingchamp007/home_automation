file.open("config.txt","r");
SSID = file.readline():gsub("%s+$", "");
PASS = file.readline():gsub("%s+$", "");
IP = file.readline():gsub("%s+$", "");
NETMSK = file.readline():gsub("%s+$", "");
GTY = file.readline():gsub("%s+$", "");
file.close();

wifi.setmode(wifi.STATION)
  cfg = {
      ip= IP,
      netmask= NETMSK,
      gateway= GTY
    }
  wifi.sta.setip(cfg)

  --Your router wifi network's SSID and password
  wifi.sta.config(SSID,PASS)
  --Automatically connect to network after disconnection
  wifi.sta.autoconnect(1)
  print ("\r\n")
  --Print network ip address on UART to confirm that network is connected
  print(wifi.sta.getip())
  --Create server and send html data, process request from html for relay on/off.
  srv=net.createServer(net.TCP)
  srv:listen(80,function(conn) --change port number if required. Provides flexibility when controlling through internet.
      conn:on("receive", function(client,request)
          local html_buffer = "";
          local html_buffer1 = "";
          local html_buffer2 = "";
          local html_buffer3 = "";
          local html_buffer4 = "";
          local html_buffer5 = "";
		
          local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
          if(method == nil)then
              _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
          end
          local _GET = {}
          if (vars ~= nil)then
              for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                  _GET[k] = v
              end
          end

	  	html_buffer = html_buffer.."<!DOCTYPE html>";
      html_buffer = html_buffer.."<html>";
      html_buffer = html_buffer.."<title>DB's IOT Server</title>";
      html_buffer = html_buffer.."</head>";
      html_buffer = html_buffer.."<body style = \"color: #d8fafe\">";
      html_buffer = html_buffer.."<table align = \"center\" color = \"#aaaaff\" style = \"border-width: 4px; border-style: solid; border-color:  #4eb0fd; padding:18px ; border-radius:18px\">";
      html_buffer = html_buffer.."<thead>";
      html_buffer = html_buffer.."<title>IOT Server</title>";
      html_buffer = html_buffer.."<tr>";
      html_buffer = html_buffer.."<th colspan = \"2\" style = \"border-width:3px; border-color:   #fcd4fb; border-style: solid; border-radius:18px; font-size: 90px; font-family: Arial; padding: 12px; color:   #f09b19  \">IOT Server</th>";
      html_buffer = html_buffer.."</tr>";
      html_buffer = html_buffer.."<tr>";
      html_buffer = html_buffer.."<th style = \"background-color:  #e8fcfe ; padding: 6px; font-size: 42px; color: #4eb0fd; margin:20px\" >Relay 1</th>";
      html_buffer1 = html_buffer1.."<th style = \"background-color:  #e8fcfe ; padding: 6px; font-size: 42px; color: #4eb0fd; margin:20px\" >Relay 2</th>";
      html_buffer1 = html_buffer1.."</tr>";
      html_buffer1 = html_buffer1.."</thead>";
      html_buffer1 = html_buffer1.."<tbody style = \"background-color:  #d8fafe \">";
      html_buffer1 = html_buffer1.."<tr align = \"center\">";
      html_buffer1 = html_buffer1.."<td style = \"border: 2WHIRLPOOLpx\">";
      html_buffer1 = html_buffer1.."<a href=\"?pin=ON1\"><button style = \"color: #4eb0fd; width:110px; font-family:Arial; font-size: 45px; border-radius: 30px; margin:20px; padding:5px\">ON</button></a>";
      html_buffer1 = html_buffer1.."</td>";
      html_buffer1 = html_buffer1.."<td>";
      html_buffer1 = html_buffer1.."<a href=\"?pin=ON2\"><button style = \"color: #4eb0fd; width:110px; font-family:Arial; font-size: 45px; border-radius: 30px; margin:20px; padding:5px\">ON</button></a>";
      html_buffer1 = html_buffer1.."</td> ";
      html_buffer1 = html_buffer1.."</tr>";
      html_buffer1 = html_buffer1.."<tr align = \"center\">";
      html_buffer2 = html_buffer2.."<td>";
      html_buffer2 = html_buffer2.."<a href=\"?pin=OFF1\"><button style = \"color: #4eb0fd; width:110px; font-family:Arial; font-size: 45px; border-radius: 30px; margin:20px;padding:5px\">OFF</button></a>";
      html_buffer2 = html_buffer2.."</td>";
      html_buffer2 = html_buffer2.."<td>";
      html_buffer2 = html_buffer2.."<a href=\"?pin=OFF2\"><button style = \"color: #4eb0fd; width:110px; font-family:Arial; font-size: 45px; border-radius: 30px; margin:20px; padding:5px\">OFF</button></a>";
      html_buffer2 = html_buffer2.."</td>";
      html_buffer2 = html_buffer2.."</tr>";
      html_buffer2 = html_buffer2.."</tbody>";
      html_buffer2 = html_buffer2.."</table>";
      html_buffer2 = html_buffer2.."</body>";
      html_buffer2 = html_buffer2.."</html>";
          local _on,_off = "",""
          if(_GET.pin == "ON1")then
                gpio.write(Relay1, gpio.HIGH);
          elseif(_GET.pin == "OFF1")then
                gpio.write(Relay1, gpio.LOW);
          elseif(_GET.pin == "ON2")then
                gpio.write(Relay2, gpio.LOW);
          elseif(_GET.pin == "OFF2")then
                gpio.write(Relay2, gpio.HIGH);
          end
          --Buffer is sent in smaller chunks as due to limited memory ESP8266 cannot handle more than 1460 bytes of data.
	  	    client:send(html_buffer);
          client:send(html_buffer1);
          client:send(html_buffer2);
          client:close();
          collectgarbage();
      end)
  end)
