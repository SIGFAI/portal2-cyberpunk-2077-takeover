powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"name='portal2.exe'\" | ForEach-Object { (\$_ | Invoke-CimMethod -MethodName Terminate).ReturnValue }" >/dev/null
sleep 3
