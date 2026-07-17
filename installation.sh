#! /bash/bin

chmod +x SSHcontrol
mv SSHcontrol /usr/local/bin/SSHcontrol
if ["$?" == 0]
then
	echo "installation successfully done"
	echo " command is 'SSHcontrol' "
fi
