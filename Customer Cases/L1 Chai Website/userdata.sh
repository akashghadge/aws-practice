$script = @'
#!/bin/bash
dnf install -y nginx
systemctl enable --now nginx
echo "<h1>Chai Point - Open 7am-10pm</h1>" > /usr/share/nginx/html/index.html
'@
$script = $script -replace "`r`n", "`n"
[System.IO.File]::WriteAllText("$PWD\userdata.sh", $script, (New-Object System.Text.UTF8Encoding $false))
