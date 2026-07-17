#! /bash/bin

chmod +x SSHcontrol.sh
mv SSHcontrol.sh /usr/local/bin/SSHcontrol
if ["$?" == 0]
then
	echo "installation successfully done"
	echo " command is 'SSHcontrol' "
fi
