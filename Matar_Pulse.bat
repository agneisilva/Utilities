sc config pulsesecureservice start= disabled
net stop pulsesecureservice
taskkill /im:pulsesecureservice.exe /f
taskkill /im:pulse.exe /f
sc config pulsesecureservice start= demand

net start pulsesecureservice