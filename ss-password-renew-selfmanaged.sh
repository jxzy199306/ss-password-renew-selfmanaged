
#!/bin/bash
#================================================================
# Script for Shadowsocks Multi User Password Renewing on Ubuntu/Debian
# @author minirplus
# Usage: ./ss-password-renew-selfmanaged.sh [port] [password]
# More info: https://zhongyue.site/ss_passwd_renew/
#================================================================
config_path='/etc/shadowsocks.json'
port=$1
newpasswd=$2
public_api_path='/home/wwwroot/public-api-'”$port”'.json'

# verify if port is define
if [ -z “$port” ] ; then
echo “[ERROR] you must provide the port for renew the password.”
exit 1;
fi

# get old password
old_password=$(grep "$port" "$config_path")
password_index=$(expr index "$old_password" :)
old_password=${old_password:password_index}
old_password=${old_password%%,*}
old_password=${old_password// /}
old_password=${old_password:1:$((${#old_password}-2))}
echo "your old password is $old_password"
 
# generate new password
new_password=$newpasswd
echo "your new password is $new_password"
 
# replace old password to new password
echo "replace new password $new_password to the shadowsocks config file on port $port..."
sed -i 's/'"$old_password"'/'"$new_password"'/g' "$config_path"
 
# update public api file
echo "update public api file $public_api_path..."
now=$(date +"%Y-%m-%d %T")
echo '{	
	 "update": "'"$now"'",
	 "server":"hk2.zhongyue.site",
	 "port": "'"$port"'",
	 "method":aes-cfb-256,
	 "password": "'"$new_password"'"
}' | tee "$public_api_path"
 
# restart shadowsocks service
echo "Restarting shadowsocks service..."
/etc/init.d/shadowsocks restart
 
# All Done!
echo "All Done!"
echo "You can now use new password $new_password on port $port to login shadowsocks service now!"

