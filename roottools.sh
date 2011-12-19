#!/system/bin/sh
: '

 roottools V1.4
 
 This script is a compilation of useful functions available for
 most Android devices. For best use symlink the commands in an
 updater-script for install like busybox or toolbox.
 
 
 ------------- Copyright (C) 2010 Jared Rummler (JRummy16) -------------
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
 ----------------------------------------------------------------------
'

##=============
#=== Variables:
##=============

# script info:
SCRIPT_NAME=roottools
VERSION=1.9
DEVELOPER="JRummy16 and Santiemanuel and cccb010"

# helps:
BB=busybox
DEVICE=`getprop ro.product.model | $BB tr "[:upper:]" "[:lower:]"`
. /data/liberty/init.d.conf

# directories:
HOME=/
INTERNAL_DIR=/data/magicbox
EXTERNAL_DIR=/sdcard/magicbox
LOG_FILE=/data/liberty/liberty.log

# defaults:
LOGGING=1 # logging on by default
USE_COLORS=1 # colors on by default
PROMPT_REBOOT=1

# urls:
BOOTANIMATION_URL=http://santiemanuel.grupoandroid.com/stuff/bootanimations
DONATE_LINK=http://bit.ly/iaQ7jZ
ERI81_URL=http://froyoroms.com/files/developers/jrummy/JRummy/scripts/81_eri.xml
ERI16_URL=http://froyoroms.com/files/developers/jrummy/JRummy/scripts/16_eri.xml
FONT_URL=http://santiemanuel.grupoandroid.com/stuff/fonts
THEME_URL=http://santiemanuel.grupoandroid.com/stuff/themes
CLOCK_URL=http://santiemanuel.grupoandroid.com/stuff/clock
BOOTLOGO_URL=http://santiemanuel.grupoandroid.com/stuff/bootlogos
BOOTSOUND_URL=http://santiemanuel.grupoandroid.com/stuff/bootsound
ANIM_URL=http://santiemanuel.grupoandroid.com/stuff/reanim
HOSTS_URL=http://www.froyoroms.com/files/developers/jrummy/JRummy/Other
ZIP_URL=http://www.froyoroms.com/files/developers/jrummy/JRummy/Other/zip
ZIPALIGN_BINARY=http://www.froyoroms.com/files/developers/jrummy/JRummy/Other/zipalign

##=============
#=== Functions:
##=============

roottoolsUsage()
{
	echo -e ${cyanb} ${blackf}
	echo "$SCRIPT_NAME v$VERSION"
	echo -e "Created by: ${yellowf}Jared Rummler ($DEVELOPER)${cyanb}${blackf}"
	echo 
	echo "Usage: $SCRIPT_NAME [function] [arguments]..."
	echo "   or: function [arguments]..."
	echo "         (Assuming $SCRIPT_NAME is symlinked)"
	echo 
	echo "Currently defined functions:"
	echo -e ${purplef}
	echo "ads, allinone, apploc, backup, bootani, cache,"
	echo "camsound, compcache, chglog, donate, exe, fixperms,"
	echo "freemem, install_zip, load, pulldown_text,"
	echo "install_zip, load, market_history pulldown_text,"
	echo "rb, restore,rmapk, setcpu, setprops, slim, sound,"
	echo "switch, symlink, sysro, sysrw, usb, zipalign_apks"
	echo -e ${cyanb} ${blackf}
	echo "To see options for specific commands use:"
	echo "       $SCRIPT_NAME [command] -help"
	echo "   or: [command] -help (if symlinked)"
}

checkBusybox()
{
	if /system/xbin/busybox > /dev/nul 2>&1; then
		BB=/system/xbin/busybox
	elif /system/bin/busybox > /dev/nul 2>&1; then
		BB=/system/bin/busybox
	else
		echo -e "${redf}Error:${cyanf} Busybox not found! ${reset}"
		echo "Error: Busybox not found!" >> $LOG_FILE
		exit
	fi
}

checkSD()
{
	if $BB test -z "$(mount | $BB grep /sdcard)"; then
		LOG_FILE=/data/${SCRIPT_NAME}/${SCRIPT_NAME}.log
		ECHO -l "${redf}${redf}Error:${cyanf} sdcard was not found.${reset}"
		echo "Please unmount your sdcard and try again."
		exit
	fi
}

ECHO()
{
	if $BB test "$1" = "-l" -a $LOGGING -eq 1; then
		echo "$2" "$3" | $BB tee -a $LOG_FILE
	elif $BB test "$1" = "-lo" -a $LOGGING -eq 1; then
		echo "$1" >> $LOG_FILE
	else
		if $BB test "$1" = "-l" -o "$1" = "-lo"; then
			echo "$2"
		else
			echo "$1" "$2"
		fi
	fi
}

promtReboot()
{
	if $BB test $PROMPT_REBOOT -eq 1; then
		case $1 in
			msg1) ECHO -l "For the best performance you should reboot the device." ;;
			msg2) ECHO -l "To see the changes take effect a reboot is required."   ;;
		esac
		ECHO -l -n "Would you like to reboot now? (y/n): "; read rebootChoice
		ECHO -lo $rebootChoice
		case $rebootChoice in y|Y) _rb --reboot ;; esac
	fi
}

taskRuntime()
{
	# Set START and STOP variable inbetween task
	RUNTIME=`$BB expr $STOP - $START`
	HOURS=`$BB expr $RUNTIME / 3600`
	REMAINDER=`$BB expr $RUNTIME % 3600`
	MINS=`$BB expr $REMAINDER / 60`
	SECS=`$BB expr $REMAINDER % 60`
	$BB printf "%02d:%02d:%02d\n" "$HOURS" "$MINS" "$SECS"
}

initializeColors()
{
	esc=""
	reset="${esc}[0m"
	# Foreground colors:
	bluef="${esc}[34m";    blackf="${esc}[30m";    cyanf="${esc}[36m"
	greenf="${esc}[32m";   purplef="${esc}[35m";   redf="${esc}[31m"
	whitef="${esc}[37m";   yellowf="${esc}[33m"
	# Background colors:
	blueb="${esc}[44m";    blackb="${esc}[40m";    cyanb="${esc}[46m"
	greenb="${esc}[42m";   purpleb="${esc}[45m";   redb="${esc}[41m"
	whiteb="${esc}[47m";   yellowb="${esc}[43m"
	# Misc:
	boldon="${esc}[1m";    boldoff="${esc}[22m"
	italicson="${esc}[3m"; italicsoff="${esc}[23m"
	ulon="${esc}[4m";      uloff="${esc}[24m"
	invon="${esc}[7m";     invoff="${esc}[27m"
}

_ads()
{
	getHosts()
	{
		$BB mkdir -p $INTERNAL_DIR/Hosts
		if $BB test ! -e $INTERNAL_DIR/Hosts/$1; then
			ECHO -l -n "Downloading $1 ... "
			$BB wget -q $HOSTS_URL/$1 -O $INTERNAL_DIR/Hosts/$1
			ECHO -l "done."
		fi
	}
	
	case $1 in
		off)
			getHosts hosts.local
			getHosts hosts.adblock
			cat $INTERNAL_DIR/Hosts/hosts.local > /system/etc/hosts
			cat $INTERNAL_DIR/Hosts/hosts.adblock >> /system/etc/hosts
			ECHO -l "Ads have been disabled."
		;;
		on)
			getHosts hosts.local
			cat $INTERNAL_DIR/Hosts/hosts.local > /system/etc/hosts
			ECHO -l "Ads have been enabled."
		;;
		*)
			echo "Usage: ads [on|off]"
			echo 
			echo "Blocks or shows most ads"
		;;
	esac
}

_allinone()
{
	_allinoneUsage()
	{
		echo "Usage: allinone"
		echo 
		echo "Displays a user friendly menu to run"
		echo "$SCRIPT_NAME functions."
	}
	
	backupMenu()
	{
		echo "=============================="
		echo " 1  Backup apps and data"
		echo " 2  Backup apps only"
		echo " 3  Restore apps and data"
		echo " 4  Restore apps only"
		echo " 5  Exit this menu"
		echo "=============================="
		echo -n "${redf}Please choose a number: ${blackf}"
		read backupAndRestoreChoice
		case $backupAndRestoreChoice in
			1) _backup      ;;
			2) _backup -nd  ;;
			3) _restore     ;;
			4) _restore -nd ;;
			5)              ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $backupAndRestoreChoice";;
		esac
	}

	subMenu()
	{
		EXIT_OTHERS=0
		while test $EXIT_OTHERS -eq 0; do
			echo "=========================================="
			echo " 1   Zipalign apks"
			echo " 2   Block Ads"
			echo " 3   Show Ads"
			echo " 4   Turn off camera shutter sounds."
			echo " 5   Turn on camera shutter sounds."
			echo " 6   Free Internal Memory"
			echo " 7   Fix permissions"
			echo " 8   Switch boot animations"
			echo " 9   Switch live wallpapers"
			echo " 10  Mount / unmount USB storage"
			echo " 11  Manage cache (move 2sd / wipe)"
			echo " 12  Clear market search history"
			echo " 13  Change pulldown bar text"
			echo " 14  Return to the main menu"
			echo "=========================================="
			echo -n "${redf}Please choose a number: ${blackf}"
			read scriptChoice
			case $scriptChoice in
				1)	_zipalign_apks --menu                                         ;;
				2)	_ads off                                                      ;;
				3)	_ads on                                                       ;;
				4)	_camsound off                                                 ;;
				5)	_camsound on                                                  ;;
				6)	_freemem --menu                                               ;;
				7)	_fixperms -v                                                  ;;
				8)	_switch ba                                                    ;;
				9)	_switch lwp                                                   ;;
				10)	_usb                                                          ;;
				11)	_cache --menu                                                 ;;
				12)	_market_history                                               ;;
				13)	_pulldown_text                                                ;;
				14) EXIT_OTHERS=1                                                 ;;
				*)	echo "${redf}Error:${cyanf} Invalid option in $scriptChoice"  ;;
			esac
		done
	}
	
	if $BB [ $# -gt 0 ]; then
		_allinoneUsage
		return
	fi
	
	checkSD
	EXIT_ALLINONE=0
	
	while $BB test $EXIT_ALLINONE -eq 0; do
		echo 
		echo "================================================="
		echo -e ${redf}
		echo "     ___   ____      ____         ____"
		echo "    / _ | / / /____ /  _/___ ____/ __ \___ ___"
		echo "   / __ |/ / //___/_/ / / _ |___/ /_/ / _ | -_)"
		echo "  /_/ |_/_/_/     /___//_//_/   \____/_//_|__/"
		echo 
		echo "                        ${yellowf} by: $DEVELOPER"
		echo -e ${blackf}
		echo "Battery level: $( cat /sys/devices/platform/cpcap_battery/power_supply/battery/charge_counter )"
		echo "================================================="
		echo " Choose between: 1 & 17"
		echo 
		echo " 1 Backup / Restore"
		echo " 2 Change Boot Animation"
		echo " 3 Change Fonts"
		echo " 4 Choose Apps to SD Options"
		echo " 5 Set CPU and Show CPU Info."
		echo " 6 Set build properties"
		echo " 7 Remove & Uninstall Applications"
		echo " 8 Run Other Scripts"
		echo " 9 Install themes"
		echo " 10 Change BootLogos"
		echo " 11 Change Clock Color(NEW)"
		echo " 12 Adjust init scripts (NEW)"
		echo " 13 Change Boot Sound (NEW)"
		echo " 14 Switch window Animations"
		echo " 15 Switch keylayout and keychars"
		echo " 16 Fix DNS For Faster Market"
		echo " 17 Exit This Script"
		echo "================================================="
		echo -n " ${redf}${redf}Please choose a number: ${blackf}${blackf}"; read allInOneChoice
		case $allInOneChoice in
			1) backupMenu                                                      ;;
			2) _load ba                                                        ;;
			3) _load fs                                                        ;;
			4) _apploc -m                                                      ;;
			5) _setcpu                                                         ;;
			6) _setprops                                                       ;;
			7) _rmapk -m                                                       ;;
			8) subMenu                                                         ;;
			9) _load theme                                                     ;;
			10) _load bootlogos                                                ;;
			11) _load clock                                                    ;;
			12) _setinits													   ;;
			13) _load bootsound                                                ;;
			14) _load reanim												   ;;
			15) _load keypad                                                   ;;
			16) _load dns                                                      ;;
			17) EXIT_ALLINONE=1                                                ;;
			*)	echo "${redf}Error:${cyanf} Invalid option in $allInOneChoice" ;;
		esac
	done
}

_apploc()
{
	applocUsage()
	{
		echo "Usage: apploc"
		echo 
		echo "Options:"
		echo 
		echo "  2sd     Apps will be installed to external storage"
		echo "  2in     Apps will be installed to internal storage"
		echo "  2au     System will decide where to install apps"
		echo "  -c      Prints current install location"
		echo "  -m      Print a user friendly menu for app locations"
		echo "  -help   This help"
	}
	
	getInstallLocation()
	{
		case `pm getInstallLocation | $BB sed -e 's|^..||' -e 's|.$||'` in
			auto)     echo "Auto: System will decide where apps will be installed to."     ;;
			internal) echo "Internal: Apps will be installed to internal storage."         ;;
			external) echo "External: Apps will be installed to sdcard"                    ;;
			*)        echo "${redf}Error:${cyanf} could not get current install location." ;;
		esac
	}
	
	setInstallLocation()
	{
		ECHO -l -n "Install location changed from $(pm getInstallLocation | $BB sed -e 's|^..||' -e 's|.$||') "
		pm setInstallLocation $1
		ECHO -l "to $(pm getInstallLocation | $BB sed -e 's|^..||' -e 's|.$||')"
	}
	
	installLocationMenu()
	{
		echo "=========================================================="
		echo " Your current install location is: ${whitef}$(pm getInstallLocation | $BB cut -c 2-)"
		echo " 1  [external]: Install on external storage (sdcard)."
		echo " 2  [internal]: Install on internal device storage."
		echo " 3  [auto]: Let system decide the best location."
		echo " 4  Exit this menu"
		echo "=========================================================="
		echo -n "${redf}Please choose a number: ${blackf}"; read locationChoice
		case $locationChoice in
			1) setInstallLocation 2                                           ;;
			2) setInstallLocation 1                                           ;;
			3) setInstallLocation 0                                           ;;
			4)                                                                ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $locationChoice" ;;
		esac
	}
	
	case $1 in
		-c)  getInstallLocation   ;;
		2sd) setInstallLocation 2 ;;
		2in) setInstallLocation 1 ;;
		2au) setInstallLocation 0 ;;
		-m)	 installLocationMenu  ;;
		*)   applocUsage          ;;
	esac
}


_backup()
{
	BACKUP_DATA=1 # app data backup on by default
	BACKUP_DIR=$EXTERNAL_DIR/backup
	APP_BACKUP_DIR=$BACKUP_DIR/app
	DATA_BACKUP_DIR=$BACKUP_DIR/data
	MISC_BACKUP_DIR=$BACKUP_DIR/misc
	PACKAGE_LIST=$BACKUP_DIR/packages.list
	
	backupUsage()
	{
		echo " usage: backup [-nd|-l]"
		echo 
		echo " options:"
		echo 
		echo "   -nd    backup apps only (no data)"
		echo "   -l     turn off logging for this run"
		echo "   -help  this help"
		exit
	}
	
	case $1 in
		-nd)   BACKUP_DATA=0 ;;
		-l)    LOGGING=0     ;;
		-help) backupUsage   ;;
	esac
	
	checkSD
	
	ECHO -l
	ECHO -l -e "${yellowf}backup started at $($BB date +"%m-%d-%Y %H:%M:%S")${blackf}"
	ECHO -l
	
	START=`$BB date +%s`

	# Make directories if any are not found:
	if $BB test ! -d $BACKUP_DIR -o $APP_BACKUP_DIR -o $DATA_BACKUP_DIR -o $MISC_BACKUP_DIR; then
		$BB mkdir -p $BACKUP_DIR $APP_BACKUP_DIR $DATA_BACKUP_DIR $MISC_BACKUP_DIR
	fi
	# Create the package list if not found:
	if $BB test ! -e $PACKAGE_LIST; then
		> $PACKAGE_LIST
	fi
	
	
	# Set package count variables:
	packageCurrent=0
	packageTotal=`$BB grep codePath /data/system/packages.xml | $BB grep -v /system/ | $BB wc -l`

	# Get package name, path and code version for all apps excluding system:
	$BB grep codePath /data/system/packages.xml | $BB grep -v /system/ | $BB sed -e 's|"||g' -e 's|.*name=||g' -e 's|codePath=||g' -e 's|apk.*version=|apk |g' | $BB awk '{print $1" "$2" "$3}' | while read packageName codePath version; do
		
		packageCurrent=$(($packageCurrent+1))
		ECHO -l "Processing ${yellowf}($packageCurrent of $packageTotal)${blackf}: $packageName ... "
		
		# Create a list of packages with their current code version:
		if $BB test -z "$($BB grep $packageName $PACKAGE_LIST)"; then
			echo "$packageName $version" >> $PACKAGE_LIST
			checkForVersion=0
		else
			checkForVersion=1
		fi
		
		# Backup the app:
		if $BB test -e $APP_BACKUP_DIR/$packageName.apk -a $checkForVersion -eq 1; then
			oldVersion=`$BB grep "$packageName " $PACKAGE_LIST | $BB awk '{print $2}'`
			if $BB test $oldVersion -ne $version; then
				$BB cp -f $codePath $APP_BACKUP_DIR/$packageName.apk
				$BB sed -i "s|$packageName.*$oldVersion|$packageName $version|g" $PACKAGE_LIST
				ECHO -l "   [${yellowf}X${blackf}] Updated $packageName version code $oldVersion to $version."
			else
				ECHO -l "   [${yellowf}X${blackf}] Skipped app backup for $packageName (backup is up-to-date)"
			fi
		else
			$BB cp -f $codePath $APP_BACKUP_DIR/$packageName.apk
			ECHO -l "   [${yellowf}X${blackf}] Backed up: $codePath"
		fi
		
		# Backup app data:
		if $BB test $BACKUP_DATA -eq 1 -a -d /data/data/$packageName; then
			if $BB test -d $DATA_BACKUP_DIR/$packageName; then
				dataBackupMsg="   [${yellowf}X${blackf}] Updated data backup for $packageName."
			else
				dataBackupMsg="   [${yellowf}X${blackf}] Backed up data for $packageName."
			fi
			if $BB test $($BB find /data/data/$packageName -type f | $BB wc -l) -ne 0; then
				$BB cp -R /data/data/$packageName $DATA_BACKUP_DIR/$packageName > /dev/nul 2>&1
				ECHO -l "$dataBackupMsg"
			else
				ECHO -l "   [${redf}!${blackf}] Skipped empty data directory for $packageName"
			fi
		fi
	done
	
	# Clean up packages.list:
	ECHO -l
	ECHO -l "Finishing up ... "
	for i in `cat $PACKAGE_LIST | $BB awk '{print $1}'`; do
		if $BB test -z "`ls $APP_BACKUP_DIR | $BB grep $i.apk`"; then
			$BB sed -i "s|.*$i.*||g" $PACKAGE_LIST
			ECHO -l "Removed $i from package list (non-existant file)"
		fi
	done
	
	STOP=`$BB date +%s`

	ECHO -l
	ECHO -l "${yellowf}backup runtime: $(taskRuntime)${blackf}"
	ECHO -l
}

_bootani()
{
	case $1 in
		-d)
			ECHO -l -n "Disabling boot animation ... "
			$BB find /data/local /system/media -name bootanimation.zip -exec sh -c 'busybox mv -f {} `busybox dirname {}`/bootanimation.bak' ';'	
			ECHO -l "done."
		;;
		-e)
			ECHO -l -n "Enabling boot animation ... "
			$BB find /data/local /system/media -name bootanimation.bak -exec sh -c 'busybox mv -f {} `busybox dirname {}`/bootanimation.zip' ';'
			if $BB test -e /system/bin/bootanimation.bak; then
				$BB mv -f /system/bin/bootanimation.bak /system/bin/bootanimation
			fi
			ECHO -l "done."
		;;
		-r)
			ECHO -l -n "Disabling full boot animation ... "
			$BB find /data/local /system/media -name bootanimation.zip -exec sh -c 'busybox mv -f {} `busybox dirname {}`/bootanimation.bak' ';'
			if $BB test -e /system/bin/bootanimation; then
				$BB mv -f /system/bin/bootanimation /system/bin/bootanimation.bak
			fi
			ECHO -l "done."
		;;
		*)
			echo "Usage: bootani [-e|-d|-r]"
			echo 
			echo "Options:"
			echo 
			echo "   -d  Disables boot animaion (faster boot time)"
			echo "   -e  Enables boot animation"
			echo "   -r  Fully removes boot animation (faster boot time)"
		;;
	esac
}

_cache()
{

	_cacheUsage()
	{
		echo "usage: cache [-rmall|-rmsd|-rmdata|-mvsd|-mvdata|"
		echo "              -m|-mv <package>|-rm <package>]"
		echo 
		echo "options:"
		echo 
		echo "  -m            Prints menu with options"
		echo "  -rmall        Clear out all cache in /data & /sdcard"
		echo "  -rmsd         Clear out all cache in /sdcard"
		echo "  -rmdata       Clear out all cache in /data"
		echo "  -rm <package> Clear out cache for specified package"
		echo "  -mvsd         Move cache from /data to /sdcard"
		echo "  -mvdata       Move cache from /sdcard to /data"
		echo "  -mv <package> Move specified package cache to SD"
	}
	
	cacheMenu()
	{
		echo "======================================="
		echo " 1  Clear all sdcard & data cache"
		echo " 2  Clear all data cache"
		echo " 3  Clear all sdcard cache"
		echo " 4  Move all cache to sdcard"
		echo " 5  Move cache back to data"
		echo " 6  Exit this menu"
		echo "======================================="
		echo -n "${redf}Please choose a number: ${blackf}"
		read cacheChoice
		case $cacheChoice in
			1)  _cache -rmall    ;;
			2)  _cache -rmdata   ;;
			3)  _cache -rmsd     ;;
			4)  _cache -mvsd     ;;
			5)  _cache -mvdata   ;;
			6)                   ;;
			*)  echo "${redf}Error:${cyanf} Invalid option in $cacheChoice" ;;
		esac
	}
	
	clearCache()
	{
		cacheDir=$1
		
		if $BB test ! -d $cacheDir; then
			if $BB test ! -d /data/data/$cacheDir; then
				echo "${redf}Error:${cyanf} No cache found for $cacheDir"
				return
			else
				cacheDir=/data/data/$1
			fi
		fi
		
		MEMORY_BEFORE=$($BB du -sk $cacheDir | $BB awk '{print $1}')
		CURRENT=1
		
		ECHO -l "${yellowf}Cleaning out cache ... ${blackf}"
		ECHO -l
		
		$BB find $cacheDir -type d -print | $BB grep -i cache | while read d; do
			CACHE_SUM=$($BB find $d -type f | $BB wc -l)
			$BB find $d -type f -print | while read i; do
				if $BB test `echo $i | $BB sed 's|/| |g' | $BB awk '{print $1}')` != "data"; then
					CACHE_LOC=sdcard
				else
					CACHE_LOC=`echo $i | $BB sed 's|/| |g' | $BB awk '{print $3}')`
				fi
				ECHO -l -n "$CACHE_LOC ${yellowf}($CURRENT of $CACHE_SUM)${blackf} Removing: $($BB basename $i) ... "
				$BB rm -f $i
				ECHO -l "done."
				CURRENT=$(($CURRENT+1))
			done
		done
		
		FREED_MEMORY=$($BB dc $MEMORY_BEFORE `$BB du -sk $cacheDir | $BB awk '{print $1}'` - p)
		if $BB test $FREED_MEMORY -lt 1024; then
			FREED_MEMORY=$($BB dc $MEMORY_BEFORE `$BB du -sk $cacheDir | $BB awk '{print $1}'` - p)kb
		else
			FREED_MEMORY=$($BB dc $MEMORY_BEFORE `$BB du -sk $cacheDir | $BB awk '{print $1}'` 1024 - / p)mb
		fi
		
		ECHO -l 
		ECHO -l "Cache cleared! Freed $FREED_MEMORY"
	}
	
	moveCacheToSD()
	{
		cacheDir=$1
		
		if $BB test ! -d $cacheDir; then
			if $BB test ! -d /data/data/$cacheDir; then
				echo "${redf}Error:${cyanf} No cache found for $cacheDir"
				return
			else
				cacheDir=/data/data/$1
			fi
		fi
		
		ECHO -l "Moving cache to SD card ... "
		ECHO -l
		$BB mkdir -p /mnt/sdcard/data_cache
		
		$BB find $cacheDir -type d -iname cache -print | while read d
		do
			package=$(echo $d | $BB sed 's|/| |g' | $BB awk '{print $3}')
			if $BB test ! -h $d; then
				ECHO -l -n "moving cache for $package to sdcard ... "
				echo "$d" >> /mnt/sdcard/data_cache/cache.list
				$BB mkdir -p /mnt/sdcard/data_cache/$package/cache
				$BB rm -R $d
				$BB ln -s /mnt/sdcard/data_cache/$package/cache $d
				ECHO -l "done."
			else
				ECHO -l "Skipping $package ... (cache is already symlinked)"
			fi
		done
		ECHO -l "Cache was moved to SD card!"
	}
	
	moveCacheToData()
	{
		if $BB test ! -e /mnt/sdcard/data_cache/cache.list; then
			echo "${redf}Error:${cyanf} No cache found on sdcard"
			return
		fi
		
		ECHO -l "Moving cache to /data ... "
		ECHO -l
		
		for cache in `$BB cat /mnt/sdcard/data_cache/cache.list`
		do
			package=$(echo $cache | $BB sed 's|/| |g' | $BB awk '{print $3}')
			ECHO -l -n "Moving cache for $package to /data ... "
			if $BB test -d $cache -a -h $cache; then
				$BB rm -R $cache
				$BB mkdir -p $cache
			fi
			ECHO -l "done."
		done
		
		$BB rm -R /mnt/sdcard/data_cache
		echo "Cache was moved to data!"
	}
	
	case $1 in
		-m)         cacheMenu                                      ;;
		-rm)        clearCache "$2"                                ;;
		-mv)        moveCacheToSD "$2"                             ;;
		-rmall)     clearCache /mnt/sdcard; clearCache /data/data  ;;
		-rmsd)      clearCache /mnt/sdcard                         ;;
		-rmdata)    clearCache /data/data                          ;;
		-mvsd)      moveCacheToSD /data/data                       ;;
		-mvdata)    moveCacheToData                                ;;
		*)          _cacheUsage                                    ;;
	esac
}

_camsound()
{
	moveSounds()
	{
		$BB find /system/media/audio/ui -name *$1* -exec busybox mv -f {} /system/media/audio/ui/$1.$2 ';'
	}
	
	case $1 in
		off)
			moveSounds camera_click bak
			moveSounds VideoRecord bak
			ECHO -l "Camera sounds have been disabled."
		;;
		on)
			moveSounds camera_click ogg
			moveSounds VideoRecord ogg
			ECHO -l "Camera sounds have been enabled."
		;;
		*)
			echo "Usage: camsound sound [on|off]"
			echo 
			echo "Turns the camera sounds (shutter and video cam) on or off"
		;;
	esac
}

_compcache()
{
	DEV=/dev/block/ramzswap0
	MODULE=ramzswap.ko
	MODULES_DIR=/system/lib/modules
	
	compcacheUsage()
	{
		echo "Usage:"
		echo "    compcache [on|off|stats]"
		echo 
		echo "Turns compcache (in-RAM swap) on or off"
	}
	
	if $BB test $# == 0; then
		compcacheUsage
		return
	elif $BB test ! -e $MODULES_DIR/$MODULE -o -z `which rzscontrol`; then
		ECHO -l "${redf}Error:${cyanf} System does not support compcache."
		return
	fi

	case $1 in
		on|start)
			ECHO -l -n "Enabling compcache ... "
			echo 3 > /proc/sys/vm/drop_caches
			$BB insmod $MODULES_DIR/$MODULE
			rzscontrol $DEV --init
			rzscontrol /dev/block/ramzswap0 --init
			$BB swapon $DEV
			ECHO -l "done."
		;;
		off|stop)
			ECHO -l -n "Disabling compcache ... "
			$BB swapoff $DEV >/dev/null 2>&1
			$BB rmmod $MODULE >/dev/null 2>&1
			ECHO -l "done."
		;;
		stats)
			rzcontrol $DEV --stats
		;;
		*)
			compcacheUsage
		;;
	esac
}

_chglog()
{
	if $BB test $# -gt 0; then
		echo "Usage: chglog"
		echo 
		echo "Shows the changelog for your current ROM"
	fi
	
	changeLog=`$BB find /system/etc -iname *changelog*`
	
	if $BB test -z "$changeLog"; then
		ECHO -l "${redf}Error:${cyanf} changelog not found."
	else
		cat $changeLog
	fi
}


_donate()
{
	if $BB test $# -gt 0; then
		echo "Usage: Donate to the developer of $SCRIPT_NAME ($DEVELOPER)"
		echo "       Donations are appreciated :)"
	fi
	
	ECHO -l "Connecting to paypal ... "
	am start -a android.intent.action.VIEW -d $DONATE_LINK > /dev/null
}

_exe()
{
	exeUsage()
	{
		echo "usage: exe <path to file> or <file name>"
		echo 
		echo "Makes any file executable. You may either enter"
		echo "the full path to the file or the file name."
		echo "Ex: exe my_script or exe /system/xbin/my_script"
	}
	
	if $BB test $1 = "-help" -o $# == 0; then
		_exeUsage
	elif $BB test -e $1; then
		$BB chmod 0755 $1
		ECHO -l "$1 is now executable."
	# make all files which match the given name executable.
	elif $BB test -n "`$BB find /system /data /mnt/sdcard -name $1 -type f`"; then
		$BB find /system /data /mnt/sdcard -type f -name "$1" -exec $BB chmod 0755 {} ';' -exec echo "{} is now executable." ';'
	else
		ECHO -l "${redf}Error:${cyanf} $1 not found."
		echo 
		exeUsage
	fi
}


_fixperms()
{
  : 'Created by: Cyanogen, ankn, smeat, thenefield, farmatito, rikupw and Kastro 
  ** Slightly modified by JRummy16 ** '
	
	VERSION="2.04"
	
	# Defaults
	DEBUG=0 # Debug off by default
	VERBOSE=1 # Verbose on by default
	
	# Messages
	UID_MSG="Changing user ownership for:"
	GID_MSG="Changing group ownership for:"
	PERM_MSG="Changing permissions for:"
	
	# Initialise vars
	CODEPATH=""
	UID=""
	GID=""
	PACKAGE=""
	REMOVE=0
	NOSYSTEM=0
	ONLY_ONE=""
	SIMULATE=0
	DATAMOUNT=0
	SYSSDMOUNT=0
	fpStartTIME=$( $BB date +"%m-%d-%Y %H:%M:%S" )
	fpStartEPOCH=$( $BB date +%s )
	
	if $BB test "$SD_EXT_DIRECTORY" = ""; then
		#check for mount point, /system/sd included in tests for backward compatibility
		for MP in /sd-ext /system/sd; do
			if $BB test -d $MP; then
				SD_EXT_DIRECTORY=$MP
				break
			fi
		done
	fi
	
	_fixpermsUsage()
	{
		echo "Usage fixpers [OPTIONS] [APK_PATH]"
		echo "      -d         turn on debug"
		echo "      -f         fix only package APK_PATH"
		echo "      -l         disable logging for this run (faster)"
		echo "      -r         remove stale data directories"
		echo "                 of uninstalled packages while fixing permissions"
		echo "      -s         simulate only"
		echo "      -u         check only non-system directories"
		echo "      -v         disable verbosity for this run (less output)"
		echo "      -V         print version"
		echo "      -h         this help"
	}
	
	fpParseargs()
	{
	  # Parse options
		while $BB test $# -ne 0; do
			case "$1" in
				-d)
					DEBUG=1
				;;
				-f)
					if $BB test $# -lt 2; then
						echo "$0: missing argument for option $1"
						exit 1
					else
						if $BB test $( echo $2 | $BB cut -c1 ) != "-"; then
							ONLY_ONE=$2
							shift;
						else
							echo "$0: missing argument for option $1"
						exit 1
						fi
					fi
				;;
				-r)
					REMOVE=1
				;;
				-s)
					SIMULATE=1
				;;
				-l)
					if $BB test $LOGGING -eq 0; then
						LOGGING=1
					else
						LOGGING=0
					fi
				;;
				-v)
					if $BB test $VERBOSE -eq 0; then
						VERBOSE=1
					else
						VERBOSE=0
					fi
				;;
				-u)
					NOSYSTEM=1
				;;
				-V)
					echo "$0 $VERSION"
					exit 0
				;;
				-h)
					_fixpermsUsage
					exit 0
				;;
				-*)
					echo "$0: unknown option $1"
					echo
					_fixpermsUsage
					exit 1
				;;
			esac
			shift;
		done
	}
	
	fpPrint()
	{
		MSG=$@
		if $BB test $LOGGING -eq 1; then
			echo $MSG | $BB tee -a $LOG_FILE
		else
			echo $MSG
		fi
	}
	
	fpStart()
	{

		if $BB test $( $BB grep -c " /data " "/proc/mounts" ) -eq 0; then
			$BB mount /data > /dev/null 2>&1
			DATAMOUNT=1
		fi

		if $BB test -e /dev/block/mmcblk0p2 && $BB test $( $BB grep -c " $SD_EXT_DIRECTORY " "/proc/mounts" ) -eq 0; then
			$BB mount $SD_EXT_DIRECTORY > /dev/null 2>&1
			SYSSDMOUNT=1
		fi

		if $BB test $( $BB mount | $BB grep -c /sdcard ) -eq 0; then
			LOG_FILE="/data/fix_permissions.log"
		else
			LOG_FILE="/mnt/sdcard/fix_permissions.log"
		fi
		if $BB test ! -e "$LOG_FILE"; then
			> $LOG_FILE
		fi
	   echo 
	   fpPrint "${yellowf}$0 $VERSION started at $fpStartTIME${blackf}"
	   echo 
	}
	
	fpChownUid()
	{
		FP_OLDUID=$1
		FP_UID=$2
		FP_FILE=$3

		#if user ownership doesn't equal then change them
		if $BB test "$FP_OLDUID" != "$FP_UID"; then
			if $BB test $VERBOSE -ne 0; then
				fpPrint "$UID_MSG $FP_FILE from '$FP_OLDUID' to '$FP_UID'"
			fi
			if $BB test $SIMULATE -eq 0; then
				$BB chown $FP_UID "$FP_FILE"
			fi
		fi
	}
	
	fpChownGid()
	{
		FP_OLDGID=$1
		FP_GID=$2
		FP_FILE=$3

		#if group ownership doesn't equal then change them
		if $BB test "$FP_OLDGID" != "$FP_GID"; then
			if $BB test $VERBOSE -ne 0; then
				fpPrint "$GID_MSG $FP_FILE from '$FP_OLDGID' to '$FP_GID'"
			fi
			if $BB test $SIMULATE -eq 0; then
				$BB chown :$FP_GID "$FP_FILE"
			fi
		fi
	}
	
	fpChmod()
	{
		FP_OLDPER=$1
		FP_OLDPER=$( echo $FP_OLDPER | cut -c2-10 )
		FP_PERSTR=$2
		FP_PERNUM=$3
		FP_FILE=$4

		#if the permissions are not equal
		if $BB test "$FP_OLDPER" != "$FP_PERSTR"; then
			if $BB test $VERBOSE -ne 0; then
				fpPrint "$PERM_MSG $FP_FILE from '$FP_OLDPER' to '$FP_PERSTR' ($FP_PERNUM)"
			fi
			#change the permissions
			if $BB test $SIMULATE -eq 0; then
				$BB chmod $FP_PERNUM "$FP_FILE"
			fi
		fi
	}
	
	fpAll()
	{
		FP_NUMS=$( $BB cat /data/system/packages.xml | $BB egrep "^<package.*serId" | $BB grep -v framework-res.apk | $BB grep -v com.htc.resources.apk | $BB wc -l )
		I=0
		$BB cat /data/system/packages.xml | $BB egrep "^<package.*serId" | $BB grep -v framework-res.apk | $BB grep -v com.htc.resources.apk | while read all_line; do
			I=$( $BB expr $I + 1 )
			fpPackage "$all_line" $I $FP_NUMS
		done
	}
	
	fpSingle()
	{
		FP_SFOUND=$( $BB cat /data/system/packages.xml | $BB egrep "^<package.*serId" | $BB grep -v framework-res.apk | $BB grep -v com.htc.resources.apk | $BB grep -i $ONLY_ONE | $BB wc -l )
		if $BB test $FP_SFOUND -gt 1; then
			fpPrint "Cannot perform single operation on $FP_SFOUND matched package(s)."
		elif $BB test $FP_SFOUND = "" -o $FP_SFOUND -eq 0; then
			fpPrint "Could not find the package you specified in the packages.xml file."
		else
			FP_SPKG=$( $BB cat /data/system/packages.xml | $BB egrep "^<package.*serId" | $BB grep -v framework-res.apk | $BB grep -v com.htc.resources.apk | $BB grep -i $ONLY_ONE )
			fpPackage "${FP_SPKG}" 1 1
		fi
	}
	
	fpPackage()
	{
		pkgline=$1
		curnum=$2
		endnum=$3
		CODEPATH=$( echo $pkgline | $BB sed 's%.* codePath="\(.*\)".*%\1%' |  $BB cut -d '"' -f1 )
		PACKAGE=$( echo $pkgline | $BB sed 's%.* name="\(.*\)".*%\1%' | $BB cut -d '"' -f1 )
		UID=$( echo $pkgline | $BB sed 's%.*serId="\(.*\)".*%\1%' |  $BB cut -d '"' -f1 )
		GID=$UID
		APPDIR=$( echo $CODEPATH | $BB sed 's%^\(.*\)/.*%\1%' )
		APK=$( echo $CODEPATH | $BB sed 's%^.*/\(.*\..*\)$%\1%' )
		
		#debug
		if $BB test $DEBUG -eq 1; then
			fpPrint "CODEPATH: $CODEPATH APPDIR: $APPDIR APK:$APK UID/GID:$UID:$GID"
		fi
		
		#check for existence of apk
		if $BB test -e $CODEPATH;  then
			fpPrint "Processing ($curnum of $endnum): $PACKAGE..."

			#lets get existing permissions of CODEPATH
			OLD_UGD=$( $BB ls -ln "$CODEPATH" )
			OLD_PER=$( echo $OLD_UGD | $BB cut -d ' ' -f1 )
			OLD_UID=$( echo $OLD_UGD | $BB cut -d ' ' -f3 )
			OLD_GID=$( echo $OLD_UGD | $BB cut -d ' ' -f4 )

			#apk source dirs
			if $BB test "$APPDIR" = "/system/app"; then
				#skip system apps if set
				if $BB test "$NOSYSTEM" = "1"; then
					fpPrint "***SKIPPING SYSTEM APP ($PACKAGE)!"
					return
				fi
				fpChownUid $OLD_UID 0 "$CODEPATH"
				fpChownGid $OLD_GID 0 "$CODEPATH"
				fpChmod $OLD_PER "rw-r--r--" 644 "$CODEPATH"
			elif $BB test "$APPDIR" = "/data/app" || $BB test "$APPDIR" = "/sd-ext/app"; then
				fpChownUid $OLD_UID 1000 "$CODEPATH"
				fpChownGid $OLD_GID 1000 "$CODEPATH"
				fpChmod $OLD_PER "rw-r--r--" 644 "$CODEPATH"
			elif $BB test "$APPDIR" = "/data/app-private" || $BB test "$APPDIR" = "/sd-ext/app-private"; then
				fpChownUid $OLD_UID 1000 "$CODEPATH"
				fpChownGid $OLD_GID $GID "$CODEPATH"
				fpChmod $OLD_PER "rw-r-----" 640 "$CODEPATH"
			fi
		else
			fpPrint "$CODEPATH does not exist ($curnum of $endnum). Reinstall..."
			if $BB test $REMOVE -eq 1; then
				if $BB test -d /data/data/$PACKAGE ; then
					fpPrint "Removing stale dir /data/data/$PACKAGE"
					if $BB test $SIMULATE -eq 0 ; then
						$BB rm -R /data/data/$PACKAGE
					fi
				fi
			fi
		fi
		
		#the data/data for the package
		if $BB test -d "/data/data/$PACKAGE"; then
			#find all directories in /data/data/$PACKAGE
			$BB find /data/data/$PACKAGE -type d -exec $BB ls -ldn {} \; | while read dataline; do
				#get existing permissions of that directory
				OLD_PER=$( echo $dataline | $BB cut -d ' ' -f1 )
				OLD_UID=$( echo $dataline | $BB cut -d ' ' -f3 )
				OLD_GID=$( echo $dataline | $BB cut -d ' ' -f4 )
				FILEDIR=$( echo $dataline | $BB cut -d ' ' -f9 )
				FOURDIR=$( echo $FILEDIR | $BB cut -d '/' -f5 )
				
				#set defaults for iteration
				ISLIB=0
				REVPERM=755
				REVPSTR="rwxr-xr-x"
				REVUID=$UID
				REVGID=$GID
				
				if $BB test "$FOURDIR" = ""; then
					#package directory, perms:755 owner:$UID:$GID
					fpChmod $OLD_PER "rwxr-xr-x" 755 "$FILEDIR"
				elif $BB test "$FOURDIR" = "lib"; then
					#lib directory, perms:755 owner:1000:1000
					#lib files, perms:755 owner:1000:1000
					ISLIB=1
					REVPERM=755
					REVPSTR="rwxr-xr-x"
					REVUID=1000
					REVGID=1000
					fpChmod $OLD_PER "rwxr-xr-x" 755 "$FILEDIR"
				elif $BB test "$FOURDIR" = "shared_prefs"; then
					#shared_prefs directories, perms:771 owner:$UID:$GID
					#shared_prefs files, perms:660 owner:$UID:$GID
					REVPERM=660
					REVPSTR="rw-rw----"
					fpChmod $OLD_PER "rwxrwx--x" 771 "$FILEDIR"
				elif $BB test "$FOURDIR" = "databases"; then
					#databases directories, perms:771 owner:$UID:$GID
					#databases files, perms:660 owner:$UID:$GID
					REVPERM=660
					REVPSTR="rw-rw----"
					fpChmod $OLD_PER "rwxrwx--x" 771 "$FILEDIR"
				elif $BB test "$FOURDIR" = "cache"; then
					#cache directories, perms:771 owner:$UID:$GID
					#cache files, perms:600 owner:$UID:GID
					REVPERM=600
					REVPSTR="rw-------"
					fpChmod $OLD_PER "rwxrwx--x" 771 "$FILEDIR"
				else
					#other directories, perms:771 owner:$UID:$GID
					REVPERM=771
					REVPSTR="rwxrwx--x"
					fpChmod $OLD_PER "rwxrwx--x" 771 "$FILEDIR"
				fi
				
				#change ownership of directories matched
				if $BB test "$ISLIB" = "1"; then
					fpChownUid $OLD_UID 1000 "$FILEDIR"
					fpChownGid $OLD_GID 1000 "$FILEDIR"
				else
					fpChownUid $OLD_UID $UID "$FILEDIR"
					fpChownGid $OLD_GID $GID "$FILEDIR"
				fi
				
				#if any files exist in directory with improper permissions reset them
				$BB find $FILEDIR -type f -maxdepth 1 ! -perm $REVPERM -exec $BB ls -ln {} \; | while read subline; do
					OLD_PER=$( echo $subline | $BB cut -d ' ' -f1 )
					SUBFILE=$( echo $subline | $BB cut -d ' ' -f9 )
					fpChmod $OLD_PER $REVPSTR $REVPERM "$SUBFILE"
				done
				
				#if any files exist in directory with improper user reset them
				$BB find $FILEDIR -type f -maxdepth 1 ! -user $REVUID -exec $BB ls -ln {} \; | while read subline; do
					OLD_UID=$( echo $subline | $BB cut -d ' ' -f3 )
					SUBFILE=$( echo $subline | $BB cut -d ' ' -f9 )
					fpChownUid $OLD_UID $REVUID "$SUBFILE"
				done
				
				#if any files exist in directory with improper group reset them
				$BB find $FILEDIR -type f -maxdepth 1 ! -group $REVGID -exec $BB ls -ln {} \; | while read subline; do
					OLD_GID=$( echo $subline | $BB cut -d ' ' -f4 )
					SUBFILE=$( echo $subline | $BB cut -d ' ' -f9 )
					fpChownGid $OLD_GID $REVGID "$SUBFILE"
				done
			done
		fi
	}
	
	dateDiff()
	{
		if $BB test $# -ne 2; then
			FP_DDM="E"
			FP_DDS="E"
			return
		fi
		FP_DDD=$( $BB expr $2 - $1 )
		FP_DDM=$( $BB expr $FP_DDD / 60 )
		FP_DDS=$( $BB expr $FP_DDD % 60 )
	}
	
	fpEnd()
	{
		if $BB test $SYSSDMOUNT -eq 1; then
			$BB umount $SD_EXT_DIRECTORY > /dev/null 2>&1
		fi

		if $BB test $DATAMOUNT -eq 1; then
			$BB umount /data > /dev/null 2>&1
		fi

		fpEndTIME=$( $BB date +"%m-%d-%Y %H:%M:%S" )
		fpEndEPOCH=$( $BB date +%s )

		dateDiff $fpStartEPOCH $fpEndEPOCH
		echo 
		fpPrint "${yellowf}$0 $VERSION ended at $fpEndTIME (Runtime:${FP_DDM}m${FP_DDS}s)${blackf}"
		echo 
	}
	
	fpParseargs $@
	fpStart
	if $BB test "$ONLY_ONE" != "" -a "$ONLY_ONE" != "0" ; then
	   fpSingle "$ONLY_ONE"
	else
	   fpAll
	fi
	fpEnd
}

_freemem()
{
	freememUsage()
	{
		echo "Usage: freemem [-m|50mb|75mb|100mb|default]"
		echo 
		echo "Configures the system to enusre that at least a given"
		echo "amount of RAM is always available."
		echo "-m will print a menu of choices."
	}
	
	freeMemory()
	{
		echo "$1,$2,$3,$4,$5,$6" > /sys/module/lowmemorykiller/parameters/minfree
		ECHO -l "Set ${redf}$($BB expr $6 \* 4 / 1024)mb${blackf} of RAM free."
	}
	
	freeMemoryMenu()
	{
		echo "======================="
		echo " 1. Free 25mb of RAM"
		echo " 2. Free 50mb of RAM"
		echo " 3. Free 75mb of RAM"
		echo " 4. Free 100mb of RAM"
		echo " 5. Exit this menu"
		echo "======================="
		echo
		echo -n "${redf}Please choose a number: ${blackf}"; read freeMemoryChoice
		case $freeMemoryChoice in
			1) freeMemory 1536 2048 4096 5120 5632 6144                         ;;
			2) freeMemory 2560 3840 6400 7680 10240 12800                       ;;
			3) freeMemory 2560 3840 6400 10240 12800 19200                      ;;
			4) freeMemory 2560 3840 6400 12800 12800 25600                      ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $freeMemoryChoice" ;;
		esac
	}
	
	case $1 in
		-m|-menu)  freeMemoryMenu                              ;;
		50|50mb)   freeMemory 2560 3840 6400 7680 10240 12800  ;;
		75|75mb)   freeMemory 2560 3840 6400 10240 12800 19200 ;;
		100|100mb) freeMemory 2560 3840 6400 12800 12800 25600 ;;
		25|25mb)   freeMemory 1536 2048 4096 5120 5632 6144    ;;
		*)         freememUsage                                ;;
	esac
}

_install_zip()
{
	# User defined:
	USE_LIST_FROM_SERVER=0
	PACKAGE_LIST_FROM_SERVER="" # file on your server that can be constantly updated
	AVAILABLE_PACKAGES_LIST=$EXTERNAL_DIR/tmp/update_packages.list
	DOWNLOAD_DIR=$EXTERNAL_DIR/downloads # must be on sdcard

	install_zipUsage()
	{
		echo 
		echo " Usage: `$BB basename $0` [-m|-i|path/to/zip]"
		echo 
		echo " Options:"
		echo "     -m             Lists a menu of available packages"
		echo "     -i             Installs specified available package"
		echo "     <path/to/zip>  Installs specified zip"
		echo 
		exit $?
	}

	installZip()
	{
		if $BB test $GET_ZIP -eq 1; then
			if $BB test ! -d $DOWNLOAD_DIR; then
				$BB mkdir -p $DOWNLOAD_DIR
			elif $BB test -e $DOWNLOAD_DIR/`$BB basename $UPDATE_PACKAGE`; then
				echo -n "Removing old update package ... "
				$BB rm -f $DOWNLOAD_DIR/`$BB basename $UPDATE_PACKAGE`
				echo "done."
			fi
			echo "Downloading `$BB basename $UPDATE_PACKAGE` ... "
			$BB wget $UPDATE_PACKAGE -O $DOWNLOAD_DIR/`$BB basename $UPDATE_PACKAGE`
		fi
		echo -n "Preparing for install ... "
		$BB mkdir -p /cache/recovery
		echo "install_zip SDCARD:"$(echo "$DOWNLOAD_DIR/`$BB basename $UPDATE_PACKAGE`" | $BB sed 's|.*sdcard/||')"" >> /cache/recovery/extendedcommand
		echo "done."
		echo 
		echo "Rebooting into recovery to apply update package ... "
		sleep 2s
		if $BB test "$DEVICE" = "A953" -o "$DEVICE" = "droid2"; then
			> /data/.recovery_mode
			reboot
		else
			reboot recovery
		fi
	}

	if $BB test $# -eq 0; then
		install_zipUsage
	fi
	
	if $BB test ! -d "`$BB dirname $AVAILABLE_PACKAGES_LIST`"; then
		$BB mkdir -p "`$BB dirname $AVAILABLE_PACKAGES_LIST`"
	fi
	if $BB test $USE_LIST_FROM_SERVER -eq 1; then
		$BB wget -q $PACKAGE_LIST_FROM_SERVER -O $AVAILABLE_PACKAGES_LIST
	else
		: '
		Description and then link goes below
		use a seperate line for each update package
		Example:
		This is an awesome update http://awesome.com/files/really/awesome/update.zip
		'
		cat > $AVAILABLE_PACKAGES_LIST << UPDATE_PACKAGES
UPDATE_PACKAGES
	fi

	case $1 in
		-m|--menu)
			echo "============================================="
			N=1
			while read line; do
				WORD_COUNT=`echo $line | $BB wc -w`
				URL=`echo $line | $BB awk -v n=$WORD_COUNT '{print $n}'`
				echo " $N. $line" | $BB sed "s|$URL||"
				N=$(($N+1))
			done < $AVAILABLE_PACKAGES_LIST
			echo " $N. Exit this menu"
			echo "============================================="
			echo -n "${redf}Please choose a number: ${blackf}";read CHOICE
			if $BB test $CHOICE -eq $N; then
				exit $?
			elif $BB test -z "`$BB sed -n "$CHOICE{p;q;}" $AVAILABLE_PACKAGES_LIST`"; then
				echo "${redf}Error:${cyanf} Invalid choice in $CHOICE"
				exit $?
			fi
			PACKAGE_WORD_COUNT=`$BB sed -n "$CHOICE{p;q;}" $AVAILABLE_PACKAGES_LIST | $BB wc -w`
			UPDATE_PACKAGE=`$BB sed -n "$CHOICE{p;q;}" $AVAILABLE_PACKAGES_LIST | $BB awk -v n=$PACKAGE_WORD_COUNT '{print $n}'`
			echo -n "Are you sure you want to continue and install `$BB basename $UPDATE_PACKAGE`? (y/n): ";read CHECK
			case $CHECK in
				y|Y) GET_ZIP=1;installZip;;
				*)   echo "Installation aborted.";;
			esac		
		;;
		-i|--install)
			if $BB test -z "$2"; then
				install_zipUsage
			fi
			while read line; do
				WORD_COUNT=`echo $line | $BB wc -w`
				URL=`echo $line | $BB awk -v n=$WORD_COUNT '{print $n}'`
				if $BB test -n "`echo $URL | $BB grep "$2"`"; then
					UPDATE_PACKAGE=$URL
				fi
			done < $AVAILABLE_PACKAGES_LIST
			if $BB test -z "$UPDATE_PACKAGE"; then
				echo "${redf}Error:${cyanf} $2 is not an available update package"
				exit $?
			fi
			GET_ZIP=1
			installZip
		;;
		*)
			if $BB test ! -e "$1"; then
				install_zipUsage
			fi
			echo -n "${yellowf}Are you sure you want to install $1? (y/n): ${blackf}";read INSTALL_CHOICE
			case $INSTALL_CHOICE in
				y|Y) UPDATE_PACKAGE=$1;GET_ZIP=0;installZip;;
				*)   echo "Installation aborted.";;
			esac
		;;
	esac
}

_load()
{
	NO_MENU=0
	
	loadUsage()
	{
		echo " Usage: load [ba|exa|theme|bootlogos|bootsound|fs|clock|lwp]"
		echo 
		echo " options:"
		echo 
		echo "  ba  | --bootani    Lists bootanimations to install"
		echo "  fs  | --fonts      Lists custom fonts to install"
	}
	
	installBootAnimations()
	{
		BOOTANIMATION_DIR=$EXTERNAL_DIR/goodies/bootanimations
		
		loadBootAnimation()
		{
			if $BB test ! -e $BOOTANIMATION_DIR/$1/bootanimation.zip; then
				ECHO -l "Downloading bootanimation ..."
				$BB mkdir -p $BOOTANIMATION_DIR/$1
				$BB wget $BOOTANIMATION_URL/$1/bootanimation.zip -O $BOOTANIMATION_DIR/$1/bootanimation.zip
			fi
			ECHO -l -n "Removing old bootanimation.zip ... "
			$BB find /system/media /data/local -name bootanimation.zip -exec $BB rm -f {} ';'
			ECHO -l "done."
			ECHO -l -n "Installing bootanimation.zip ... "
			$BB cp -f $BOOTANIMATION_DIR/$1/bootanimation.zip /data/local
			$BB chmod 0655 /data/local/bootanimation.zip
			ECHO -l "done."
			ECHO -l "Rebooting to show off the new bootanimation."
			prepareShutdown
			reboot
		}
		
		if $BB test $NO_MENU -eq 0; then
			echo "=========================================================="
			echo " 1   Atrix 4G (NEW)          2   Android Logo"
			echo " 3   Bloody                  4   Bios (NEW)"
			echo " 5   GreenStatDroid (NEW)    6   Droid X"
			echo " 7   Fade my Evo             8   Jurassic Park"
			echo " 9   lcars boot              10  Nexus one"
			echo " 11  Android Kill Apple(NEW) 12  Rotting Apple"
			echo " 13  Splash Inverted         14  Stick Fight"
			echo " 15  HoneyBee (NEW)          16  Honey (NEW)"
			echo " 17  Banana                  18  Cyanogen "
			echo " 19  Cyberchaos              20  Deception"
			echo " 21  Evo 4G                  22  Froyo Droid"
			echo " 23  Cyanogen 7 (NEW)        24  Cyborg Creation (NEW)"
			echo " 25  Droid one               26  Piss on Apple"
			echo " 27  Spinning Droids         28  Squares"
			echo " 29  Super Mario             30  GreenDroidoes (NEW)"
			echo " 31  OrangeDroidoes (NEW)    32  TwobluesDroidoes (NEW)"
			echo " 33  Exit" 
			echo "=========================================================="
			echo -n "${redf}Please choose a number: ${blackf}"
			read bootAniChoice
		elif $BB test $NO_MENU -eq 1; then
			bootAniChoice=$2
		fi
		case $bootAniChoice in
			1|Atrix_4G)               loadBootAnimation atrix4g                  ;;
			2|android_logo)           loadBootAnimation android_logo             ;;
			3|blood)                  loadBootAnimation blood                    ;;
			4|Bios)                   loadBootAnimation bios                     ;;
			5|GreenStatDroid)         loadBootAnimation greenstaticdroid         ;;
			6|droidx)                 loadBootAnimation droidx                   ;;
			7|fade_my_evo)            loadBootAnimation fade_my_evo              ;;
			8|jurassic_park)          loadBootAnimation jurassic_park            ;;
			9|lcarsboot)              loadBootAnimation lcarsboot                ;;
			10|nexus)                 loadBootAnimation nexus                    ;;
			11|androidkillapple)      loadBootAnimation androidkillapple         ;;
			12|rottingapple)          loadBootAnimation rottingapple             ;;
			13|splash_inverted)       loadBootAnimation splash_inverted          ;;
			14|stickfight)            loadBootAnimation stickfight               ;;
			15|HoneyBee)              loadBootAnimation honeybee                 ;;
			16|Honey)                 loadBootAnimation honey                    ;;
			17|banana)                loadBootAnimation banana                   ;;
			18|Cyanogen)              loadBootAnimation cyanogen3                ;;
			19|cyberchaos)            loadBootAnimation cyberchaos               ;;
			20|deception)             loadBootAnimation deception                ;;
			21|evo_4g)                loadBootAnimation evo_4g                   ;;
			22|froyo)                 loadBootAnimation froyo                    ;;
			23|cyanogen7)             loadBootAnimation cyanogen7                ;;
			24|cyborgcreation)        loadBootAnimation cyborgcreation           ;;
			25|originalboot)          loadBootAnimation originalboot             ;;
			26|piss_on_apple)         loadBootAnimation piss_on_apple            ;;
			27|spinning_droid)        loadBootAnimation spinning_droid           ;;
			28|squares)               loadBootAnimation squares                  ;;
			29|supermario)            loadBootAnimation supermario               ;;
			30|GreenDroidoes)         loadBootAnimation greendroidoes            ;;
			31|OrangeDroidoes)        loadBootAnimation orangedroidoes           ;;
			32|TwoblueDroidoes)       loadBootAnimation twobluedroidoes          ;;
			33)                                                                  ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $bootAniChoice"     ;;
		esac
	}

	installBootsound()
	{
		BOOTSOUND_DIR=$EXTERNAL_DIR/goodies/bootsound
		
		loadBootsound()
		{
			BOOTSOUND_DIR=$EXTERNAL_DIR/goodies/bootsound
			if $BB test ! -e $BOOTSOUND_DIR/$1.mp3; then
				ECHO -l "Downloading bootsound ..."
				$BB mkdir -p $BOOTSOUND_DIR
				$BB wget $BOOTSOUND_URL/$1.mp3 -O $BOOTSOUND_DIR/$1.mp3
			fi
			ECHO -l -n "Removing old bootsound ... "
			$BB find /system/media /data/local -name android_audio.mp3 -exec $BB rm -f {} ';'
			ECHO -l "done."
			ECHO -l -n "Installing boot sound ... "
			$BB cp -f $BOOTSOUND_DIR/$1.mp3 /system/media/android_audio.mp3
			$BB chmod 0644 /system/media/android_audio.mp3
			ECHO -l "done."
			ECHO -l "Reboot to listen to the new sound, it's loud ;)."
		}
		
		if $BB test $NO_MENU -eq 0; then
			echo "=========================================================="
			echo " 1   20th FOX Theme          2   Angry Birds"
			echo " 3   Broke Glass             4   Exorcist"
			echo " 5   Horror Music            6   KillBill Whistle"
			echo " 7   Lie to Me Theme         8   Mario Bros"
			echo " 9   NFS                     10  NFS Carbon"
			echo " 11  NightClub Mix           12  Nokia Techno"
			echo " 13  Nokia Tune Rock         14  Perfect Tone"
			echo " 15  Pirates of Carribean    16  Police"
			echo " 17  Soft Morning            18  Exit "
			echo "=========================================================="
			echo -n "${redf}Please choose a number: ${blackf}"
			read bootSoundChoice
		elif $BB test $NO_MENU -eq 1; then
			bootSoundChoice=$2
		fi
		case $bootSoundChoice in
			1|20thfoxtheme)               loadBootsound 20thFoxTheme         ;;
			2|angrybirds)                 loadBootsound AngryBirds           ;;
			3|brokeglass)                 loadBootsound BrokeGlass           ;;
			4|exorcist)                   loadBootsound Exorcist             ;;
			5|horrormusic)                loadBootsound HorrorMusic          ;;
			6|killbillwhistle)            loadBootsound KillBillWhistle      ;;
			7|lietometheme)               loadBootsound LieToMeTheme         ;;
			8|mariobros)                  loadBootsound MarioBros            ;;
			9|nfs)                        loadBootsound NFS                  ;;
			10|nfscarbon)                 loadBootsound NFSCarbon            ;;
			11|nightclubmix)              loadBootsound NightClubMix         ;;
			12|nokiatechno)               loadBootsound NokiaTechno          ;;
			13|nokiatunerock)             loadBootsound NokiaTuneRock        ;;
			14|perfecttone)               loadBootsound PerfectTone          ;;
			15|piratesofcarribean)        loadBootsound PiratesOfCarribean   ;;
			16|police)                    loadBootsound Police               ;;
			17|softmorning)               loadBootsound SoftMorning          ;;
			18)                                                                  ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $bootSoundChoice"   ;;
		esac
	}
	
	installThemes()
	{
		THEME_DIR=$EXTERNAL_DIR/goodies/themes
		
		loadTheme()
		{
			THEME_DIR=$EXTERNAL_DIR/goodies/themes
			if $BB test ! -e $THEME_DIR/$1/update.zip; then
				ECHO -l "Downloading theme ..."
				$BB mkdir -p $THEME_DIR/$1
				$BB wget $THEME_URL/$1/update.zip -O $THEME_DIR/$1/update.zip
			fi
			ECHO -l "done."
			ECHO -l -n "Installing theme ... "
            echo "install_zip SDCARD:/roottools/goodies/themes/$1/update.zip" > /cache/recovery/extendedcommand
			> /data/.recovery_mode
			prepareShutdown
			ECHO -l "Rebooting to apply theme."
			sleep 5
			reboot
		}
		
		if $BB test $NO_MENU -eq 0; then
			echo "=========================================================="
			echo " No Themes Available Yet."
			echo "=========================================================="
			echo -n "${redf}Please choose a number: ${blackf}"
			read ThemeChoice
		elif $BB test $NO_MENU -eq 1; then
			ThemeChoice=$2
		fi
		case $ThemeChoice in
			*) echo "${redf}Error:${cyanf} Invalid option in $ThemeChoice"   ;;
		esac
	}

	installReanim()
	{
		APP_DIR=$EXTERNAL_DIR/goodies/metamorph
		
		loadAnim()
		{
			APP_DIR=$EXTERNAL_DIR/goodies/metamorph
			ECHO -l "Analyzing anim.zip ..."
			$BB mkdir -p $APP_DIR/reanim/res
			$BB wget $ANIM_URL/$1.zip -O $APP_DIR/reanim/res/anim.zip
			sh /system/xbin/mm.sh
		}
		
		if $BB test $NO_MENU -eq 0; then
			echo "============================================"
			echo " 1   Blur          2  Bounce"
			echo " 3   Flip          4  FlyFold"
			echo " 5   FlyIn         6  Fold"
			echo " 7   MIUIStyle     8  Slide"
			echo " 9   ICS(Default)  10 Exit"
			echo "============================================"
			echo -n "${redf}Please choose a number: ${blackf}"
			read AnimChoice
		elif $BB test $NO_MENU -eq 1; then
			AnimChoice=$2
		fi
		case $AnimChoice in
			1|Blur)                    loadAnim BlurAnim          ;;
			2|Bounce)                  loadAnim BounceAnim        ;;
			3|Flip)                    loadAnim FlipAnim          ;;
			4|FlyFold)                 loadAnim FlyFoldAnim       ;;
			5|FlyIn)                   loadAnim FlyInAnim         ;;
			6|Fold)                    loadAnim FoldAnim          ;;
			7|MIUIStyle)               loadAnim MIUIStyleAnim     ;;
			8|Slide)                   loadAnim SlideAnim         ;;
			9|ICS)                     loadAnim ICSanim           ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $AnimChoice"   ;;
		esac
	}

	installKeypad()
	{
	    FILES_DIR=/system/etc/keypads
		KEYCHARS=/system/usr/keychars
		KEYLAYOUT=/system/usr/keylayout
		
		loadKeypad()
		{
			FILES_DIR=$EXTERNAL_DIR/keypads
			KEYCHARS=/system/usr/keychars
			KEYLAYOUT=/system/usr/keylayout
			$BB cp -f $FILES_DIR/$1.kl $KEYLAYOUT/qwerty.kl
			$BB cp -f $FILES_DIR/$1.kl $KEYLAYOUT/sholes-keypad.kl
			$BB cp -f $FILES_DIR/$1.kl $KEYLAYOUT/umts_milestone2-keypad.kl
			$BB cp -f $FILES_DIR/$1.kl $KEYLAYOUT/qtouch-touchscreen.kl
			$BB cp -f $FILES_DIR/$1.kcm.bin $KEYCHARS/qwerty.kcm.bin
            gingerkeys hotreboot
		}
		
		if $BB test $NO_MENU -eq 0; then
			echo "========================================"
			echo " 1   AZERTY    2  EURO_QWERTY"
			echo " 3   QWERTY    4  QWERTZ"
			echo " 5   Exit"
			echo "========================================"
			echo -n "${redf}Please choose a number: ${blackf}"
			read KeypadChoice
		elif $BB test $NO_MENU -eq 1; then
			KeypadChoice=$2
		fi
		case $KeypadChoice in
			1|AZERTY)                loadKeypad azerty        ;;
			2|EURO_QWERTY)           loadKeypad euro-qwerty   ;;
			3|QWERTY)                loadKeypad qwerty        ;;
			4|QWERTZ)                loadKeypad qwertz        ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $KeypadChoice"   ;;
		esac
	}

	installDns()
	{
	    DNS_URL=http://santiemanuel.grupoandroid.com/stuff/dns
		DNS_DIR=/system/etc

		loadDns()
		{
	    		DNS_URL=http://santiemanuel.grupoandroid.com/stuff/dns
			DNS_DIR=/system/etc
			$BB wget $DNS_URL/$1 -O $DNS_DIR/resolv.conf
			chmod 644 $DNS_DIR/resolv.conf
			echo -l "DNS Fixed"
			sleep 1
		}
		
		if $BB test $NO_MENU -eq 0; then
			echo "========================================"
			echo " 1   GoogleDNS    2  OpenDNS"
			echo " 3   Exit"
			echo "========================================"
			echo -n "${redf}Please choose a number: ${blackf}"
			read DnsChoice
		elif $BB test $NO_MENU -eq 1; then
			DnsChoice=$2
		fi
		case $DnsChoice in
			1|Google)                loadDns google        ;;
			2|OpenDNS)               loadDns opendns       ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $DnsChoice"   ;;
		esac
	}	
	
	installClock()
	{
		CLOCK_DIR=/system/etc/clock
		
		loadClock()
		{
		    CLOCK_DIR=/system/etc/clock	
		    sysrw
		    cd $CLOCK_DIR/$1
		    zip -o -9 /system/app/SystemUI.apk res/layout/*.xml
            killall system_server
		}
		
		if $BB test $NO_MENU -eq 0; then
			echo "============================================"
			echo " 1   Blue       2  Cyan"
			echo " 3   Green      4  NoClock"
			echo " 5   Purple     6  Red"
			echo " 7   White      8  Yellow"
			echo " 9   ICS        10 Exit"
			echo "============================================"
			echo -n "${redf}Please choose a number: ${blackf}"
			read ClockChoice
		elif $BB test $NO_MENU -eq 1; then
			ClockChoice=$2
		fi
		case $ClockChoice in
			1|Blue)                     loadClock blue                       ;;
			2|Cyan)                     loadClock cyan                       ;;
			3|Green)                    loadClock green                      ;;
			4|NoClock)                  loadClock noclock                    ;;
			5|Purple)                   loadClock purple                     ;;
			6|Red)                      loadClock red                        ;;
			7|White)                    loadClock white                      ;;
			8|Yellow)                   loadClock yellow                     ;;
			9|ICS)                      loadClock ics                        ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $ClockChoice"   ;;
		esac
	}
	
	installBootLogos()
	{
		BOOTLOGO_DIR=$EXTERNAL_DIR/goodies/bootlogos
		
		loadBootLogos()
		{
			BOOTLOGO_DIR=$EXTERNAL_DIR/goodies/bootlogos
			if $BB test ! -e $BOOTLOGO_DIR/$1/update.zip; then
				ECHO -l "Downloading bootlogo ..."
				$BB mkdir -p $BOOTLOGO_DIR/$1
				$BB wget $BOOTLOGO_URL/$1/update.zip -O $BOOTLOGO_DIR/$1/update.zip
			fi
			ECHO -l "done."
			ECHO -l -n "Switching bootlogo ... "
			rm -f /data/.bootmenu_bypass && echo recovery > /cache/recovery/bootmode.conf && echo "install_zip("/sdcard/roottools/goodies/bootlogos/$1/update.zip")" > /cache/recovery/extendedcommand && reboot
		}
		
		if $BB test $NO_MENU -eq 0; then
			echo "================================================================="
			echo " 1   Alienware        2  AndroidFlame       3  AndroidGingerbread"
			echo " 4   AndroidMeetBirds 5  AndpeeingApple     6  AngryDevil"
			echo " 7   AssassinCreed    8  Baseball           9  Basketball"
			echo " 10  Batman          11  BiteTheApple      12  BOGreenAndroid"
			echo " 13  BOWhiteAndroid  14  BlueMotoLogo      15  BootStrap"
			echo " 16  BusinessAndroid 17  CallOfDuty        18  CocaCola"
			echo " 19  CrazyBall       20  D2Blue            21  DarkDroid"
			echo " 22  DragonAndroid   23  Droid2Green       24  Droid2Logo"
			echo " 25  DroidCrimes     26  DroidDoes         27  DroidDoesX"
			echo " 28  DroidEyeGFather 29  DroidEyeSeeYou    30  DroidLife"
			echo " 31  DroidPink       32  FemaleFlower      33  Football"
			echo " 34  FrozenYogurt    35  GhostBusters      36  Harley"
			echo " 37  IronMan         38  JamesBondAndroid  39  JediAndroid"
			echo " 40  Liberty         41  MiddleFingerXRay  42  Monster"
			echo " 43  MotoBell        44  MotoLogo          45  PinkAndroid"
			echo " 46  PixelMario      47  ThreedAndroid     48  USAndroid"
			echo " 49  USArmy          50  YellowAndroid     51  Argen2Stone"
            echo " 52  Argen2Graffo    53 Exit"
			echo "================================================================="
			echo -n "${redf}Please choose a number: ${blackf}"
			read BootLogoChoice
		elif $BB test $NO_MENU -eq 1; then
			BootLogoChoice=$2
		fi
		case $BootLogoChoice in
			1|Alienware)                    loadBootLogos alienware                   ;;
			2|AndroidFlame)                 loadBootLogos androidflame                ;;
			3|AndroidGingerbread)           loadBootLogos androidgingerbread          ;;
			4|AndroidMeetBirds)             loadBootLogos androidmeetangrybirds       ;;
			5|AndPeeingApple)               loadBootLogos androidpeeingonapple        ;;
			6|AngryDevil)                   loadBootLogos angrydevil                  ;;
			7|AssassinCreed)                loadBootLogos assassinscreed              ;;
			8|Baseball)                     loadBootLogos baseball                    ;;
			9|Basketball)                   loadBootLogos basketball                  ;;
			10|Batman)                      loadBootLogos batman                      ;;
			11|BiteTheApple)                loadBootLogos bitetheapple                ;;
			12|BOGreenAndroid)              loadBootLogos blackongreenandroid         ;;
			13|BOWhiteAndroid)              loadBootLogos blackonwhiteandroid         ;;
			14|BlueMotoLogo)                loadBootLogos bluemotologo                ;;
			15|Bootstrap)                   loadBootLogos bootstrap                   ;;
			16|BusinessAndroid)             loadBootLogos businessandroid             ;;
			17|CallOfDuty)                  loadBootLogos callofduty                  ;;
			18|CocaCola)                    loadBootLogos cocacola                    ;;
			19|CrazyBall)                   loadBootLogos crazyball                   ;;
			20|D2Blue)                      loadBootLogos d2blue                      ;;
			21|DarkDroid)                   loadBootLogos darkdroid                   ;;
			22|DragonAndroid)               loadBootLogos dragonandroid               ;;
			23|Droid2Green)                 loadBootLogos droid2green                 ;;
			24|Droid2Logo)                  loadBootLogos droid2logo                  ;;
			25|DroidCrimes)                 loadBootLogos droidcrimes                 ;;
			26|DroidDoes)                   loadBootLogos droiddoes                   ;;
			27|DroidDoesX)                  loadBootLogos droiddoesx                  ;;
			28|DroidEyeGFather)             loadBootLogos droideyegrandfather         ;;
			29|DroidEyeSeeYou)              loadBootLogos droideyeseeyou              ;;
			30|DroidLife)                   loadBootLogos droidlife                   ;;
			31|DroidPink)                   loadBootLogos droidpink                   ;;
			32|FemaleFlower)                loadBootLogos femaleflower                ;;
			33|Football)                    loadBootLogos football                    ;;
			34|FrozenYogurt)                loadBootLogos frozenyogurt                ;;
			35|GhostBusters)                loadBootLogos ghostbusters                ;;
			36|Harley)                      loadBootLogos harley                      ;;
			37|IronMan)                     loadBootLogos ironman                     ;;
			38|JamesBondAndroid)            loadBootLogos jamesbondandroid            ;;
			39|JediAndroid)                 loadBootLogos jediandroid                 ;;
			40|Liberty)                     loadBootLogos liberty                     ;;
			41|MiddleFingerXRay)            loadBootLogos middlefingerxray            ;;
			42|Monster)                     loadBootLogos monster                     ;;
			43|MotoBell)                    loadBootLogos motobell                    ;;
			44|MotoLogo)                    loadBootLogos motologo                    ;;
			45|PinkAndroid)                 loadBootLogos pinkandroid                 ;;
			46|PixelMario)                  loadBootLogos pixelmario                  ;;
			47|ThreedAndroid)               loadBootLogos threedandroid               ;;
			48|USAndroid)                   loadBootLogos usaandroid                  ;;
			49|USArmy)                      loadBootLogos usarmy                      ;;
			50|YellowAndroid)               loadBootLogos yellowandroid               ;;
			51|Argen2Stone)                 loadBootLogos argen2stone                 ;;
			52|Argen2Graffo)                loadBootLogos argen2graffo                ;;
			53)                                                                       ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $BootLogoChoice"         ;;
		esac
	}
	
	installFonts()
	{
		FONT_DIR=$EXTERNAL_DIR/goodies/fonts
		
		loadFonts()
		{
			echo "Hola, escribiste: "
			FONT_DIR=$EXTERNAL_DIR/goodies/fonts
			$BB mkdir -p $FONT_DIR/$1
			if $BB test `$BB find $FONT_DIR/$1 -iname *.ttf | $BB wc -l` -eq 0; then
				ECHO -l "Downloading fonts ... "
				$BB wget $FONT_URL/$1.zip -O $FONT_DIR/$1/$1.zip
				$BB unzip -o $FONT_DIR/$1/$1.zip -d $FONT_DIR/$1
				$BB rm -f $FONT_DIR/$1/$1.zip
			fi
			$BB find $FONT_DIR/$1 -iname *.ttf -print | while read ttf
			do
				$BB cp -f $ttf /system/fonts
			done
			ECHO -l "$1 fonts have been installed."
			promtReboot msg2
		}
		
		if $BB test $NO_MENU -eq 0; then
			echo "============================================="
			echo "1   Antipasto            15  Frontier"
			echo "2   Applegaramound       16  Gangsta"
			echo "3   Arial                17  Haze"
			echo "4   Bloody               18  Infected"
			echo "5   Bonzai               19  Newspapaer"
			echo "6   Broadway             20  Purisa"
			echo "7   Comic                21  Sawasdee"
			echo "8   Conforaa             22  Stock font"
			echo "9   Corsiva              23  Times"
			echo "10  Courier              24  Trebuchet"
			echo "11  Defused              25  Zegoe"
			echo "12  Dejavu               26  Zegoelight"
			echo "13  Dogtown              27  Roboto"
			echo "14  Droid                28  Exit this menu"           
			echo "============================================"
			echo -n "${redf}Please choose a number: ${blackf}"
			read fontChoice
		elif $BB test $NO_MENU -eq 1; then
			fontChoice=$2
		fi
		
		case $fontChoice in
			1|antipasto)      loadFonts antipasto                          ;;
			2|applegaramound) loadFonts applegaramound                     ;;
			3|arial)          loadFonts arial                              ;;
			4|bloody)         loadFonts bloody                             ;;
			5|bonzai)         loadFonts bonzai                             ;;
			6|broadway)       loadFonts broadway                           ;;
			7|comic)          loadFonts comic                              ;;
			8|conforaa)       loadFonts conforaa                           ;;
			9|corsiva)        loadFonts corsiva                            ;;
			10|courier)       loadFonts courier                            ;;
			11|defused)       loadFonts defused                            ;;
			12|dejavu)        loadFonts dejavu                             ;;
			13|dogtown)       loadFonts dogtown                            ;;
			14|droid)         loadFonts droid                              ;;
			15|frontier)      loadFonts frontier                           ;;
			16|gangsta)       loadFonts gangsta                            ;;
			17|haze)          loadFonts haze                               ;;
			18|infected)      loadFonts infected                           ;;
			19|newspaper)     loadFonts newspaper                          ;;
			20|purisa)        loadFonts purisa                             ;;
			21|sawasdee)      loadFonts sawasdee                           ;;
			22|stock)         loadFonts stock                              ;;
			23|times)         loadFonts times                              ;;
			24|trebuchet)     loadFonts trebuchet                          ;;
			25|zegoe)         loadFonts zegoe                              ;;
			26|zegoelight)    loadFonts zegoelight                         ;;
			27|roboto)        loadFonts roboto                             ;;
			28)                                                            ;;
			*)  echo "${redf}Error:${cyanf} Invalid option in $fontChoice" ;;
		esac
	}
	
	if $BB test "$1" = "-nm"; then
		NO_MENU=1
		shift;
	fi
	
	case $1 in
	    theme) installThemes $@        ;;
		ba) installBootAnimations $@ ;;
		fs) installFonts $@          ;;
		foss) loadFonts $@          ;;
		bootlogos) installBootLogos $@ ;;
		clock) installClock $@        ;;
		bootsound) installBootsound $@ ;;  
		reanim) installReanim $@      ;;
		keypad) installKeypad $@      ;;
		dns) installDns $@            ;;
		*)  loadUsage                ;;
	esac
}

_market_history()
{
	if $BB test $# -gt 0; then
		echo "usage: market_history"
		echo 
		echo "Clears market search history"
	fi
	
	$BB find /data/data/com.android.vending -iname suggestions.db -exec $BB rm -f {} ';'
	ECHO -l "Market search history has been cleared."
}

_pulldown_text()
{
	WORKPLACE=/data/local
		
	if $BB test $# -gt 0; then
		echo "Usage: eri"
		echo 
		echo "Changes the \"Verizon Wireless\" in the"
		echo "pulldown bar to your own custom text."
		return
	fi
	
	eriTextChanger()
	{
		# Set variables:
		OLD_PWD=`$BB pwd`
		NEW_PWD=$WORKPLACE/eri/tmp
		case $COUNT in
			81)
				ORIGINAL_TEXT="this can say whatever your heart desires and it can be as long as this message is"
				ERI_URL=$ERI81_URL
			;;
			16)
				ORIGINAL_TEXT="Verizon Wireless"
				ERI_URL=$ERI16_URL
			;;
		esac
		
		# Get users input:
		ECHO -l
		ECHO -l -n "Please type what you would like the pulldown bar to say: "; read NEW_TEXT
		
		# Check the character count:
		if $BB test `echo "$NEW_TEXT" | $BB wc -L` -gt $COUNT; then
			ECHO -l "${redf}Error:${cyanf} You cannot set the text to more than $COUNT characters."
			ECHO -l "Please try again."
			return
		fi
		
		# Get the correct amount of characters:
		while $BB test `echo "$NEW_TEXT" | $BB wc -L` -ne $COUNT
		do
			NEW_TEXT="$NEW_TEXT "
		done
		
		# Attempt to get the original file:
		if $BB test $COUNT -eq 16 -a ! -e system/etc/"$COUNT"_eri.xml; then
			ECHO -l "Attempting to extract eri.xml from your framework ... "
			$BB mkdir -p $WORKPLACE/eri/tmp
			$BB cp -f /system/framework/framework-res.apk $WORKPLACE/eri/tmp.zip
			$BB unzip -q $WORKPLACE/eri/tmp.zip -d $WORKPLACE/eri/tmp >/dev/null 2>&1
			$BB rm -f $WORKPLACE/eri/tmp.zip
		fi
		
		# Make sure we have eri.xml:
		if $BB test ! -e system/etc/"$COUNT"_eri.xml; then
			
			# Show error if extracting the xml from framework failed:
			# (unzip fails frequently with framework-res.apk)
			if $BB test $COUNT -eq 16; then
				ECHO -l
				ECHO -l "${redf}Error:${cyanf} extracting eri.xml failed."
				ECHO -l "To continue, we must attempt to download the xml."
				ECHO -l
			fi
			
			# Warn user of potential outcomes:
			ECHO -l "Warning: this xml file may not be compatible with your framework!"
			ECHO -l "There is a chance that using this custom xml file will put you into"
			ECHO -l "a boot loop!"
			ECHO -l
			ECHO -l -n "Would you like to continue to download the file despite this warning? (y/n): "; read WARNING
			case $WARNING in n|N) return ;; esac
			
			# Download custom eri.xml:
			ECHO -l
			ECHO -l -n "Downloading xml file ... "
			$BB mkdir -p $WORKPLACE/eri/tmp/res/xml
			$BB wget -q $ERI_URL -O $WORKPLACE/eri/tmp/res/xml/eri.xml
			ECHO -l "done"
			
			# Make a backup of the file for later changes:
			if $BB test -e $WORKPLACE/eri/tmp/res/xml/eri.xml; then
				$BB cp -f $WORKPLACE/eri/tmp/res/xml/eri.xml system/etc/"$COUNT"_eri.xml
			else
				# wget is borked in some versions of busybox so 
				# after all that it can still fail o_O
				ECHO -l "${redf}Error:${cyanf} could not retrieve eri.xml!"
				return
			fi	
		else
			$BB mkdir -p $WORKPLACE/eri/tmp/res/xml
			$BB cp -f system/etc/"$COUNT"_eri.xml $WORKPLACE/eri/tmp/res/xml/eri.xml
		fi
			
		# Make sure eri.xml has the original text:
		if $BB test -z "`$BB grep "$ORIGINAL_TEXT" $WORKPLACE/eri/tmp/res/xml/eri.xml`"; then
			ECHO -l "${redf}Error:${cyanf} eri.xml has been changed or is corrupt!"
			return
		fi
		
		# Make the change:
		ECHO -l
		ECHO -l -n "Setting pulldown text to $NEW_TEXT ... "
		$BB sed -i "s|$ORIGINAL_TEXT|$NEW_TEXT|" $WORKPLACE/eri/tmp/res/xml/eri.xml
		cd $NEW_PWD
		zip -o /system/framework/framework-res.apk /res/xml/eri.xml > /dev/null 2>&1
		cd $OLD_PWD
		$BB rm -R $WORKPLACE/eri/tmp
		ECHO -l "done."
		promtReboot msg2
	}
	
	# Check for zip command:
	if $BB test ! -e /system/bin/zip -a ! -e /system/xbin/zip; then
		ECHO -l -n "Downloading needed files for $SCRIPT_NAME $VERSION ... "
		$BB wget -q $ZIP_URL -O /system/xbin/zip
		$BB chmod 755 /system/xbin/zip
		ECHO -l "done."
	fi
	
	echo 
	echo "===================================================="
	echo " Welcome to eri text changer by $DEVELOPER."
	echo " This will attempt to change the text in your"
	echo " pulldown bar that usually says \"Verizon Wireless\""
	echo "----------------------------------------------------"
	echo " 1. Set message with 16 characters or less"
	echo " 2. Set message with 81 characters or less"
	echo " 3. Exit this menu"
	echo "====================================================="
	echo
	echo -n "${redf}Please choose a number: ${blackf}"; read ERI
	echo 
	case $ERI in
		1) COUNT=16 ; eriTextChanger                           ;;
		2) COUNT=81 ; eriTextChanger                           ;;
		3)                                                     ;;
		*) echo "${redf}Error:${cyanf} Invalid option in $ERI" ;;
	esac
}

_rb()
{
	prepareShutdown()
	{
		stop dhcpcd;
		sleep 1;
		for i in `cat /proc/mounts | $BB cut -f 2 -d " "`
		do
			$BB mount -o remount,ro $i > /dev/nul 2>&1
		done
		sync
	}
	
	case $1 in
		""|--reboot)
			ECHO -l "See you soon ... "
			prepareShutdown
			reboot
		;;
		-r|--recovery)
			ECHO -l "Booting into recovery ... "
			prepareShutdown
			reboot recovery
		;;
		-p|--power)
			ECHO -l "Goodbye ... "
			prepareShutdown
			reboot -p
		;;
		-bs|--bootstrap)
			ECHO -l "Booting into bootstrap recovery ... "
			> /data/.recovery_mode
			prepareShutdown
			reboot
		;;
		*)
			echo "Usage: rb [-r|-p|-bs]"
			echo 
			echo "options:"
			echo "   (default)  reboots device"
			echo "   -r         reboot into recovery"
			echo "   -p         powers down device"
			echo "   -bs        reboots into bootstrap recovery"
		;;
	esac
}

_restore()
{
	RESTORE_DATA=1
	BACKUP_DIR=$EXTERNAL_DIR/backup
	APP_BACKUP_DIR=$BACKUP_DIR/app
	DATA_BACKUP_DIR=$BACKUP_DIR/data
	MISC_BACKUP_DIR=$BACKUP_DIR/misc
	PACKAGE_LIST=$BACKUP_DIR/packages.list
	
	case $1 in
		-nd)   RESTORE_DATA=0 ;;
		-help|-h) 
		echo 
		echo 
		echo 
		exit   ;;
	esac
	
	if $BB test ! -e $PACKAGE_LIST; then
		echo "${redf}Error:${cyanf} No backup found!" | $BB tee -a $LOG_FILE
		return
	elif $BB test -z "$(cat $PACKAGE_LIST)"; then
		echo "${redf}Error:${cyanf} package list is empty. Exiting ... " | $BB tee -a $LOG_FILE
		return
	fi
	
	ECHO -l
	ECHO -l "${yellowf}restore started at $($BB date +"%m-%d-%Y %H:%M:%S")${blackf}"
	ECHO -l
	
	START=`$BB date +%s`
	
	packageCurrent=0
	packageTotal=`cat $PACKAGE_LIST | $BB awk '{print $1}' | $BB wc -l`
	
	for package in `cat $PACKAGE_LIST | $BB awk '{print $1}' | $BB sort`; do
		
		packageCurrent=$(($packageCurrent+1))
		echo "Processing ${yellowf}($packageCurrent of $packageTotal)${blackf}: $package ... " | $BB tee -a $LOG_FILE
		
		if $BB test -e $APP_BACKUP_DIR/$package.apk; then
			echo -n "   [${yellowf}X${blackf}] Installing $package.apk ... " | $BB tee -a $LOG_FILE
			if $BB test -z "`pm install -r $APP_BACKUP_DIR/$package.apk 2>/dev/null`"; then
				echo "failed!" | $BB tee -a $LOG_FILE
			else
				echo "done!" | $BB tee -a $LOG_FILE
			fi
		else
			echo "   [${redf}!${blackf}] $package.apk not found. Skipped restore." | $BB tee -a $LOG_FILE
		fi
		
		if $BB test $RESTORE_DATA -eq 1; then
			if $BB test -d $DATA_BACKUP_DIR/$package; then
				echo -n "   [${yellowf}X${blackf}] Restoring data for $package ... "
				$BB cp -R $DATA_BACKUP_DIR/$package /data/data/
				echo "done!"
				fixPermissions -v -f $package
			else
				echo "   [${redf}!${blackf}] No data was found for $package" | $BB tee -a $LOG_FILE
			fi
		fi
	done
	_fixperms -v -r -u
	
	STOP=`$BB date +%s`
	
	ECHO -l
	ECHO -l "${yellowf}restore runtime: $(taskRuntime)${blackf}"
	ECHO -l
}


_rmapk()
{
	rmapkUsage()
	{
		echo "Usage:"
		echo "    rmapk [-m|browser|calc|carhome|corpcal|clock|"
		echo "          clock|email|facebook|gallery|genie|"
		echo "          launcher|lwp|maps|mms|music|pandora|"
		echo "          qoffice|spare|talk|twitter|youtube]"
		echo 
		echo "Removes and uninstalls unwanted apps from /system"
		echo 
		echo "--menu will print a user friendly menu with options."
		echo "If you do rmapk [partial name of any apk] it will"
		echo "search for any apk that matches and prompt you if"
		echo "you would like to uninstall the app"
	}
	
	removeAnyApp()
	{
		if $BB test -z "`$BB ls /system/app | $BB grep -i "$1"`" > /dev/null 2>&1; then
			ECHO -l "${redf}Error:${cyanf} $1 not found in /system/app!"
			ECHO -l
			rmapkUsage
		else
			for apk in `ls /system/app | $BB grep -i "$1"`; do	# Find the app with any partial name match.
				packageName=$(pm list packages -f | $BB grep $apk | $BB sed "s|.*$apk=||g")	# get the apps package name for pm uninstall
				if $BB test $PROMPTREMOVE -eq 1; then
					ECHO -l -n "${redf}Continue to remove and uninstall `$BB basename $apk`? (y/n): ${blackf}"
					read uninstallChoice
					case $uninstallChoice in
						y|Y)
							ECHO -l -n "Removing and uninstalling `$BB basename $apk` ... "
							$BB rm -f /system/app/$apk
							if $BB test `pm uninstall $packageName 2>/dev/null` == "Success"; then
								ECHO -l "done."
							else
								ECHO -l "${redf}Uninstall failed for `$BB basename $apk`!${blackf}"
							fi
						;;
					esac
				else
					ECHO -l -n "Removing and uninstalling `$BB basename $apk` ... "
					$BB rm -f /system/app/$apk
					if $BB test `pm uninstall $packageName 2>/dev/null` == "Success"; then
						ECHO -l "done."
					else
						ECHO -l "Uninstall failed for `$BB basename $apk`!"
					fi
				fi
			done
		fi
	}
	
	PROMPTREMOVE=0
	if $BB test $# -eq 0; then
		rmapkUsage
	fi
	
	while $BB test $# -ne 0; do
		case $1 in
			-m|--menu)
				PROMPTREMOVE=0
				echo "====================================="
				echo "1   Browser"
				echo "2   Calculator"
				echo "3   Calendar"
				echo "4   Car Home"
				echo "5   Desk Clock"
				echo "6   Email"
				echo "7   Facebook"
				echo "8   LatinIME"
				echo "9   Maps"
				echo "10  Mms"
				echo "11  Music"
				echo "10  Pandora"
				echo "13  Quick Office"
				echo "14  Spare Parts"
				echo "15  Talk"
				echo "16  You Tube"
				echo "17  Twitter"
				echo "18. You choose which apps to delete."
				echo "19. Exit this menu."
				echo "====================================="
				echo -n "${redf}Please choose a number: ${blackf}"
				read removeChoice
				case $removeChoice in
					1)	removeAnyApp Browser     ;;
					2)	removeAnyApp Calculator  ;;
					3)	removeAnyApp Calendar    ;;
					4)	removeAnyApp CarHome     ;;
					5)	removeAnyApp DeskClock   ;;
					6)	removeAnyApp Email       ;;
					7)	removeAnyApp Facebook    ;;
					8)	removeAnyApp LatinIme    ;;
					9)	removeAnyApp Maps        ;;
					10)	removeAnyApp Mms         ;;
					11)	removeAnyApp Music       ;;
					12)	removeAnyApp Pandora     ;;
					13)	removeAnyApp QuickOffice ;;
					14)	removeAnyApp SpareParts  ;;
					15)	removeAnyApp Talk.apk    ;;
					16)	removeAnyApp YouTube     ;;
					17)	removeAnyApp Twitter     ;;
					18) PROMPTREMOVE=0
						echo 
						echo "====================================="
						$BB ls /system/app
						echo 
						ECHO -l -n "Please type the name of the app you wish to uninstall: "; read removeUserChoice
						ECHO -lo "$removeUserChoice"
						for userInput in $removeUserChoice; do 	# Allow for multiple entries.
							for apk in `$BB ls /system/app | $BB grep -i $userInput`; do
								removeAnyApp $apk
							done
						done;;															
					19) ;;
					*)  echo "${redf}Error:${cyanf} Invalid option in $removeChoice" ;;
				esac
			;;
			browser)   removeAnyApp browser.apk  ;;
			calc)      removeAnyApp calculator   ;;
			carhome)   removeAnyApp carhome      ;;
			corpcal)   removeAnyApp corpcal      ;;
			clock)     removeAnyApp deskclock.apk;;
			email)     removeAnyApp email        ;;
			facebook)  removeAnyApp facebook     ;;
			gallery)   removeAnyApp gallery      ;;
			genie)     removeAnyApp geniewidget  ;;
			launcher)  removeAnyApp launcher2    ;;
			lwp)       removeAnyApp wallpapers   ;;
			maps)      removeAnyApp maps         ;;
			mms)       removeAnyApp mms          ;;
			music)     removeAnyApp music        ;;
			pandora)   removeAnyApp pandora      ;;
			qoffice)   removeAnyApp quickoffice  ;;
			spare)     removeAnyApp spareparts   ;;
			talk)      removeAnyApp talk.apk     ;;
			twitter)   removeAnyApp twitter      ;;
			youtube)   removeAnyApp youtube      ;;
			*)	
				if $BB test "$1" = "-help"; then
					rmapkUsage
					return
				fi
				PROMPTREMOVE=0
				for userInput in $1 	# Allow for multiple entries.
				do
					for apk in `$BB ls /system/app | $BB grep -i $userInput`; do
						removeAnyApp $apk
					done
				done
			;;
		esac
		shift;
	done
}

_setcpu()
{
	# Variables:
	AVAILABLE_FREQ="/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies"
	AVAILABLE_GOVERNORS="/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors"

	setThis()
	{
		# Apply frequencies/governors:
		echo "$1" > /sys/devices/system/cpu/cpu0/cpufreq/$2
		echo "${yellowf}Applied: $1${blackf}"
	}

	printMenu()
	{
		# Print menu of available frequencies/governors:
		LIST=1
		echo "===================================="
		for freq in `$BB cat $1`; do
			echo " $LIST  $freq MHz"
			LIST=$(($LIST+1))
		done
		echo " $LIST  Exit this menu"
		echo "===================================="
	}

	setFreq()
	{

		# Set max/min frequency from users choice:
		AVAILABLE_FREQ="/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies"
		AVAILABLE_GOVERNORS="/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors"
		printMenu $AVAILABLE_FREQ
		ECHO -l "Your current $1 freq. is: "`$BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_"$1"_freq`""
		ECHO -l
		echo -n "${redf}Please choose a number: ${blackf}"; read FREQ_CHOICE
		
		NEW_FREQ=`$BB cat $AVAILABLE_FREQ | $BB awk -v n="$FREQ_CHOICE" '{print $n}'`
		if $BB test $FREQ_CHOICE == $LIST; then
			return
		elif $BB test -z "$NEW_FREQ"; then
			ECHO -l "${redf}Error:${cyanf} Invalid choice in $FREQ_CHOICE"
			return
		else
			# Make sure min is not greater than max:
			if $BB test $1 == "min"; then
				if $BB test $NEW_FREQ -gt `$BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq`; then
					ECHO -l "${redf}Error:${cyanf} Can't set minimum speed higher than maximum speed"
					return
				fi
			# Make sure max is not less than min:
			elif $BB test $1 == "max"; then
				if $BB test $NEW_FREQ -lt `$BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq`; then
					ECHO -l "${redf}Error:${cyanf} Can't set maximum speed lower than minimum speed"
					return
				fi
			fi
		fi
		# Set the new frequency:
		echo "$NEW_FREQ" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_"$1"_freq
	}

	setGov()
	{
		# Set the scaling governor from the users choice:
		printMenu $AVAILABLE_GOVERNORS
		ECHO -l "Your current governor is: "`$BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`""
		ECHO -l
		echo -n "${redf}Please choose a number: ${blackf}"; read GOV_CHOICE
		NEW_GOVERNOR=`$BB cat $AVAILABLE_GOVERNORS | $BB awk -v n="$GOV_CHOICE" '{print $n}'`
		if $BB test -z "$NEW_GOVERNOR"; then
			echo "${redf}Error:${cyanf} Invalid choice in $GOV_CHOICE"
			return
		fi
		setThis $NEW_GOVERNOR scaling_governor
	}

	

	EXIT=0
	while $BB test $EXIT -eq 0; do
		echo "==========================================="
		echo " Please choose an option to perform below:"
		echo 
		echo " 1.  Set Maximum Frequency."
		echo " 2.  Set Minimum Frequency."
		echo " 3.  Set Scaling Governor."
		echo " 4.  Show CPU Info."
		echo " 5.  Exit this menu"
		echo "==========================================="
		echo 
		echo -n "${redf}Please choose a number: ${blackf}"; read SETCPU
		case $SETCPU in
			1) setFreq max                                                ;;
			2) setFreq min                                                ;;
			3) setGov                                                     ;;
			4) cpuInfo                                                    ;;
			5) EXIT=1                                                     ;;
			*) echo "${redf}Error:${cyanf} invalid option in $SETCPU"     ;;
		esac
	done
}

_setprops()
{
	setpropsUsage()
	{
		echo "Usage: setprops"
		echo 
		echo "Prints a menu to set various build properties"
	}
	
	changePropValue()
	{
		KEY=`echo $2 | $BB sed 's|=||'`

		# Check if the property exists:
		if $BB test -z "`getprop $KEY`" -a -z "`$BB grep $2 $1`"; then
			ECHO -l "${redf}Error:${cyanf} build property not supported for your device"
			return
		fi

		# Make a backup of the file if no backup was found
		$BB mkdir -p $INTERNAL_DIR/backup
		if $BB test ! -e $INTERNAL_DIR/backup/`$BB basename $1`; then
			$BB cp -f $1 $INTERNAL_DIR/backup/`$BB basename $1`
		fi

		# Make the change:
		$BB sed -i "s|$2.*|$2$3|" $1
		echo "Set $KEY to $3"
		promtReboot msg2
	}
	
	videoBitRate()
	{
		# Description: enable hq video recording on froyo.
		# Usage: videoBitRate <value>
		# Has some bugs so won't use it until I figure it out. Plus it's not really a prop value :-/
		
		OLD_VALUE=`$BB grep bitRate= /system/etc/media_profiles.xml | $BB sed -n "1{p;q;}" | $BB cut -c 29-35`
		echo -n "Changing bit rate from $OLD_VALUE to $1 ... "
		$BB sed "-e/bitRate=.*/{;s|bitRate=.*|bitRate=\"$1\"|;:a" '-en;ba' '-e}' /system/etc/media_profiles.xml > /system/etc/tmp.txt # Change only the first instance of "bitRate=""
		NEW_VALUE=`$BB grep bitRate= /system/etc/tmp.txt | $BB sed -n "1{p;q;}" | $BB cut -c 29-35`
		if $BB test $NEW_VALUE -eq $1; then # make sure a change actually took place.
			echo "done."
			$BB mv -f /system/etc/tmp.txt /system/etc/media_profiles.xml
		else
			echo "failed."
			echo "No change was made."
		fi
	}
	
	vmHeap()
	{
		case $heapSizeChoice in
			1|12m)  changePropValue /system/build.prop "dalvik.vm.heapsize=" 32m ;;
			2|14m)  changePropValue /system/build.prop "dalvik.vm.heapsize=" 34m ;;
			3|16m)  changePropValue /system/build.prop "dalvik.vm.heapsize=" 36m ;;
			4|18m)  changePropValue /system/build.prop "dalvik.vm.heapsize=" 38m ;;
			5|20m)  changePropValue /system/build.prop "dalvik.vm.heapsize=" 40m ;;
			6|22m)  changePropValue /system/build.prop "dalvik.vm.heapsize=" 42m ;;
			7|24m)  changePropValue /system/build.prop "dalvik.vm.heapsize=" 44m ;;
			8|26m)  changePropValue /system/build.prop "dalvik.vm.heapsize=" 46m ;;
			9|28m)  changePropValue /system/build.prop "dalvik.vm.heapsize=" 48m ;;
			10|30m) changePropValue /system/build.prop "dalvik.vm.heapsize=" 50m ;;
			11|32m) changePropValue /system/build.prop "dalvik.vm.heapsize=" 52m ;;
			12|34m) changePropValue /system/build.prop "dalvik.vm.heapsize=" 54m ;;
			13|36m) changePropValue /system/build.prop "dalvik.vm.heapsize=" 56m ;;
			9)                                                                   ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $heapSizeChoice"    ;;
		esac
	}
	
	wifiScan()
	{
		case $wifiScanChoice in
			1|30)  changePropValue /system/build.prop "wifi.supplicant_scan_interval=" 30  ;;
			2|45)  changePropValue /system/build.prop "wifi.supplicant_scan_interval=" 45  ;;
			3|60)  changePropValue /system/build.prop "wifi.supplicant_scan_interval=" 60  ;;
			4|90)  changePropValue /system/build.prop "wifi.supplicant_scan_interval=" 90  ;;
			5|120) changePropValue /system/build.prop "wifi.supplicant_scan_interval=" 120 ;;
			6|180) changePropValue /system/build.prop "wifi.supplicant_scan_interval=" 180 ;;
			7)                                                                               ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $wifiScanChoice"                ;;
		esac
	}
	
	ringDelay()
	{
		case $ringDelayChoice in
			1|2250) changePropValue /system/build.prop "ro.telephony.call_ring.delay=" 2250 ;;
			2|2000) changePropValue /system/build.prop "ro.telephony.call_ring.delay=" 2000 ;;
			3|1500) changePropValue /system/build.prop "ro.telephony.call_ring.delay=" 1500 ;;
			4|1000) changePropValue /system/build.prop "ro.telephony.call_ring.delay=" 1000 ;;
			5|750)  changePropValue /system/build.prop "ro.telephony.call_ring.delay=" 750  ;;
			6|3000) changePropValue /system/build.prop "ro.telephony.call_ring.delay=" 3000 ;;
			7)                                                                              ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $ringDelayChoice"              ;;
		esac
	}
	
	maxEvents()
	{
		case $maxEventsChoice in
			1|65) changePropValue /system/build.prop "windowsmgr.max_events_per_sec=" 65 ;;
			2|60) changePropValue /system/build.prop "windowsmgr.max_events_per_sec=" 60 ;;
			3|55) changePropValue /system/build.prop "windowsmgr.max_events_per_sec=" 55 ;;
			4|50) changePropValue /system/build.prop "windowsmgr.max_events_per_sec=" 50 ;;
			5|45) changePropValue /system/build.prop "windowsmgr.max_events_per_sec=" 45 ;;
			6)                                                                           ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $maxEventsChoice"           ;;
		esac
	}

	buttonLight()
	{
		# hard key lights stay on while screen is on and not timeout
		case $buttonLightChoice in
			1|off)  changePropValue /system/build.prop "ro.mot.buttonlight.timeout=" 1 ;;
			2|on|0) changePropValue /system/build.prop "ro.mot.buttonlight.timeout=" 0 ;; 
			3)                                                                         ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $buttonLight"             ;;
		esac
	}

	proximityDelay()
	{
	  # Black screen phone delay
		case $proximityDelayChoice in
			1|450) changePropValue /system/build.prop "mot.proximity.delay=" 450   ;;
			2|400) changePropValue /system/build.prop "mot.proximity.delay=" 400   ;; 
			3|350) changePropValue /system/build.prop "mot.proximity.delay=" 350   ;;
			4|300) changePropValue /system/build.prop "mot.proximity.delay=" 300   ;;
			5|250) changePropValue /system/build.prop "mot.proximity.delay=" 250   ;;
			6|200) changePropValue /system/build.prop "mot.proximity.delay=" 200   ;;
			7|150) changePropValue /system/build.prop "mot.proximity.delay=" 150   ;;
			8|100) changePropValue /system/build.prop "mot.proximity.delay=" 100   ;;
			9)                                                                     ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $proximityDelayChoice";;
		esac
	}

	lcdDensity()
	{
		case $lcdDensityChoice in
			1|190)	changePropValue /system/build.prop "ro.sf.lcd_density=" 190     ;;
			2|200)	changePropValue /system/build.prop "ro.sf.lcd_density=" 200     ;;
			3|210)	changePropValue /system/build.prop "ro.sf.lcd_density=" 210     ;;
			4|220)	changePropValue /system/build.prop "ro.sf.lcd_density=" 220     ;;
			5|230)	changePropValue /system/build.prop "ro.sf.lcd_density=" 230     ;;
			6|240)	changePropValue /system/build.prop "ro.sf.lcd_density=" 240     ;;
			7|250)	changePropValue /system/build.prop "ro.sf.lcd_density=" 250     ;;
			8|260)	changePropValue /system/build.prop "ro.sf.lcd_density=" 260     ;;
			9|270)	changePropValue /system/build.prop "ro.sf.lcd_density=" 270     ;;
			10|280)	changePropValue /system/build.prop "ro.sf.lcd_density=" 280     ;;
			11)                                                                     ;;
			*)		echo "${redf}Error:${cyanf} Invalid option in $lcdDensityChoice";;
		esac	
	}
	
	bootSound()
	{
		case $bootSoundChoice in
			1|off) changePropValue /system/build.prop "ro.config.play.bootsound=" "0" ;;
			2|on)  changePropValue /system/build.prop "ro.config.play.bootsound=" "1" ;;
			4)                                                                                                                                                 ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $bootSoundChoice"                                                                                 ;;
		esac
	}

	stageFright()
	{
		case $stageFrightChoice in
			1|playeroff) changePropValue /system/build.prop "media.stagefright.enable-player=" false  ;;
			2|playeron)  changePropValue /system/build.prop "media.stagefright.enable-player=" true   ;;
			3|metaoff)   changePropValue /system/build.prop "media.stagefright.enable-meta=" false    ;;
			4|metaon)    changePropValue /system/build.prop "media.stagefright.enable-meta=" true     ;;
			5|scanoff)   changePropValue /system/build.prop "media.stagefright.enable-scan=" false    ;;
			6|scanon)    changePropValue /system/build.prop "media.stagefright.enable-scan=" true     ;;
			7|httpoff)   changePropValue /system/build.prop "media.stagefright.enable-http=" false    ;;
			8|httpon)    changePropValue /system/build.prop "media.stagefright.enable-http=" true     ;;
			9)                                                                                        ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $stageFrightChoice"                      ;;
		esac
	}
	
	slowFps()
	{
		case $slowFpsChoice in
			1|60) changePropValue /system/build.prop "ro.media.capture.slow.fps=" 60    ;;
			2|70) changePropValue /system/build.prop "ro.media.capture.slow.fps=" 70    ;;
			3|80) changePropValue /system/build.prop "ro.media.capture.slow.fps=" 80    ;;
			4|90) changePropValue /system/build.prop "ro.media.capture.slow.fps=" 90    ;;
			5|100)  changePropValue /system/build.prop "ro.media.capture.slow.fps=" 100 ;;
			6|110) changePropValue /system/build.prop "ro.media.capture.slow.fps=" 110  ;;
			7|120) changePropValue /system/build.prop "ro.media.capture.slow.fps=" 120  ;;
			8)                                                                          ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $slowFpsChoice"            ;;
		esac
	}
	
	fastFps()
	{
		case $fastFpsChoice in
			1|1) changePropValue /system/build.prop "ro.media.capture.fast.fps=" 1    ;;
			2|2) changePropValue /system/build.prop "ro.media.capture.fast.fps=" 2    ;;
			3|3) changePropValue /system/build.prop "ro.media.capture.fast.fps=" 3    ;;
			4|4) changePropValue /system/build.prop "ro.media.capture.fast.fps=" 4    ;;
			5|5)  changePropValue /system/build.prop "ro.media.capture.fast.fps=" 5   ;;
			6|6) changePropValue /system/build.prop "ro.media.capture.fast.fps=" 6    ;;
			7|7) changePropValue /system/build.prop "ro.media.capture.fast.fps=" 7    ;;
			8|8) changePropValue /system/build.prop "ro.media.capture.fast.fps=" 8    ;;
			9)                                                                        ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $fastFpsChoice"          ;;
		esac
	}
	
	case $1 in
		""|-m|--menu)
			EXIT_SETPROPS=0
			while $BB test $EXIT_SETPROPS -ne 1; do
				echo "==================================="
				echo " 1  Change Dalvik VM Heap Size"
				echo " 2  Change Wifi Scan Interval"
				echo " 3  Change Call Ring Delay"
				echo " 4  Enable better scrolling speed"
				echo " 5  Enable hard key lights"
				echo " 6  Black screen phone delay"
				echo " 7  Stage Fright Control"
				echo " 8  Boot sound"
				echo " 9  Change LCD Density"
				echo " 10 Change FPS for SlowMotion"
				echo " 11 Change FPS for FastMotion"
				echo " 12 Exit this menu"
				echo "==================================="
				echo -n "${redf}Please choose a number: ${blackf}"
				read setPropChoice
				case $setPropChoice in
					1) 
						echo "==================================="
						echo " Your current VM Heap Size is: $(getprop dalvik.vm.heapsize)"
						echo " 1   Set VM Heap Size to 32m"
						echo " 2   Set VM Heap Size to 34m"
						echo " 3   Set VM Heap Size to 36m"
						echo " 4   Set VM Heap Size to 38m"
						echo " 5   Set VM Heap Size to 40m"
						echo " 6   Set VM Heap Size to 42m"
						echo " 7   Set VM Heap Size to 44m"
						echo " 8   Set VM Heap Size to 46m"
						echo " 9   Set VM Heap Size to 48m"
						echo " 10  Set VM Heap Size to 50m"
						echo " 11  Set VM Heap Size to 52m"
						echo " 12  Set VM Heap Size to 54m"
						echo " 13  Set VM Heap Size to 56m"
						echo " 14  Exit this menu"
						echo "==================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read heapSizeChoice
						vmHeap
					;;
					2) 
						echo "============================================="
						echo " Your current wifi scan interval is: $(getprop wifi.supplicant_scan_interval)"
						echo " 1  Change wifi scan interval to 30 seconds"
						echo " 2  Change wifi scan interval to 45 seconds"
						echo " 3  Change wifi scan interval to 60 seconds"
						echo " 4  Change wifi scan interval to 90 seconds"
						echo " 5  Change wifi scan interval to 2 minutes"
						echo " 6  Change wifi scan interval to 3 minutes"
						echo " 7  Exit this menu"
						echo "============================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read wifiScanChoice
						wifiScan
					;;
					3) 
						echo "==============================="
						echo " Your current ring delay is set to: $(getprop ro.telephony.call_ring.delay)"
						echo " 1  Reduce ring delay by 1/4"
						echo " 2  Reduce ring delay by 1/3"
						echo " 3  Reduce ring delay in half"
						echo " 4  Reduce ring delay by 2/3"
						echo " 5  Reduce ring delay by 3/4"
						echo " 6  Set to defualt delay time"
						echo " 7  Exit this menu"
						echo "==============================="
						echo -n "${redf}Please choose a number: ${blackf}"; read ringDelayChoice
						ringDelay 
					;;
					4) 
						echo "==========================================================="
						echo " ** The lower the value the faster the scrolling speed **"
						echo " Your current events per second is: $(getprop windowsmgr.max_events_per_sec)"
						echo 
						echo " 1  Set max events per second to 65"
						echo " 2  Set max events per second to 60"
						echo " 3  Set max events per second to 55"
						echo " 4  Set max events per second to 50"
						echo " 5  Set max events per second to 45"
						echo " 6  Exit this menu"
						echo "==========================================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read maxEventsChoice
						maxEvents
					;;
					5)
						echo "=============================================================="
						echo " Hard key lights are currently $(if $BB test `getprop ro.mot.buttonlight.timeout` -eq 0; then echo on ; else echo off ; fi) while the screen is on"
						echo 
						echo " 1  Enable hard key lights to stay on while the screen is on"
						echo " 2  Disable hard key lights while the screen is on (default)"
						echo " 3  Exit this menu"
						echo "=============================================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read buttonLightChoice
						buttonLight
					;;
					6)
						echo "======================================================="
						echo " ** The lower the value the shorter the delay **"
						echo " Your current value is: `getprop mot.proximity.delay`"
						echo 
						echo " 1 Set proximity delay to 450"
						echo " 2 Set proximity delay to 400"
						echo " 3 Set proximity delay to 350"
						echo " 4 Set proximity delay to 300"
						echo " 5 Set proximity delay to 250"
						echo " 6 Set proximity delay to 200"
						echo " 7 Set proximity delay to 150"
						echo " 8 Set proximity delay to 100"
						echo " 9  Exit this menu"
						echo "======================================================"
						echo -n "${redf}Please choose a number: ${blackf}"; read proximityDelayChoice
						proximityDelay
					;;
					7)
						echo "============================"
						echo " 1  Turn Media HTTP off"
						echo " 2  Turn Media HTTP on"
						echo " 3  Turn Media Scan off"
						echo " 4  Turn Media Scan on"
						echo " 5  Turn Media Meta off"
						echo " 6  Turn Media Meta on"
						echo " 7  Turn Media Player off"
						echo " 8  Turn Media Player on"
						echo " 9  Exit this menu"
						echo "============================"
						echo -n "${redf}Please choose a number: ${blackf}"; read stageFrightChoice
						stageFright
					;;
					8)
						echo "============================"
						echo " 1  Turn boot sound off"
						echo " 2  Turn boot sound on"
						echo " 3  Exit this menu"
						echo "============================"
						echo -n "${redf}Please choose a number: ${blackf}"; read bootSoundChoice
						bootSound
					;;
					9)
						echo "================================"
						echo " 1  Set LCD Density to 190"
						echo " 2  Set LCD Density to 200"
						echo " 3  Set LCD Density to 210"
						echo " 4  Set LCD Density to 220"
						echo " 5  Set LCD Density to 230"
						echo " 6  Set LCD Density to 240"
						echo " 7  Set LCD Density to 250"
						echo " 8  Set LCD Density to 260"
						echo " 9  Set LCD Density to 270"
						echo " 10 Set LCD Density to 280"
						echo " 11 Exit this menu"
						echo "================================"
						echo -n "${redf}Please choose a number: ${blackf}"; read lcdDensityChoice
						lcdDensity
					;;
					10) 
						echo "==============================="
						echo " Current FPS for SlowMotion: $(getprop ro.media.capture.slow.fps)"
						echo " 1  Set to 60fps"
						echo " 2  Set to 70fps"
						echo " 3  Set to 80fps"
						echo " 4  Set to 90fps"
						echo " 5  Set to 100fps"
						echo " 6  Set to 110fps"
						echo " 7  Set to 120fps"
						echo " 8  Exit this menu"
						echo "==============================="
						echo -n "${redf}Please choose a number: ${blackf}"; read slowFpsChoice
						slowFps 
					;;
                    11) 
						echo "==============================="
						echo " Current FPS for FastMotion: $(getprop ro.media.capture.fast.fps)"
						echo " 1  Set to 1fps"
						echo " 2  Set to 2fps"
						echo " 3  Set to 3fps"
						echo " 4  Set to 4fps"
						echo " 5  Set to 5fps"
						echo " 6  Set to 6fps"
						echo " 7  Set to 7fps"
						echo " 8  Set to 8fps"
						echo " 9  Exit this menu"
						echo "==============================="
						echo -n "${redf}Please choose a number: ${blackf}"; read fastFpsChoice
						fastFps 
					;;					
					12)
						EXIT_SETPROPS=1
					;;
					*)
						echo "${redf}Error:${cyanf} Invalid option in $setPropChoice"
					;;
				esac
			done
		;;
		vmheap)
			heapSizeChoice=$2
			vmHeap
		;;
		wifiscan)
			wifiScanChoice=$2
			wifiScan
		;;
		ringdelay)
			ringDelayChoice=$2
			ringDelay
		;;
		maxevents)
			maxEventsChoice=$2
			maxEvents
		;;
		buttonlight)
			buttonLightChoice=$2
			buttonLight
		;;
		proximity)
			proximityDelayChoice=$2
			proximityDelay
		;;
		bootsound)
			bootSoundChoice=$2
			bootSound
		;;
		stagefright)
			stageFrightChoice=$2
			stageFright
		;;
		density)
			lcdDensityChoice=$2
			lcdDensity
		;;
		slowfps)
		    slowFpsChoice=$2
			slowFps
		;;
        fastfps)
		    fastFpsChoice=$2
			fastFps
		;;		
		getprops)
			GETPROP_VALUE=$($BB cat $2 | $BB grep -i $3 | $BB sed "s|$3||")
			if $BB test -z "$GETPROP_VALUE"; then
				echo "${redf}Error:${cyanf} could not get prop value."
			else
				echo $GETPROP_VALUE
			fi
		;;
		*)
			setpropsUsage
		;;
	esac
}

_setinits()
{
	vmHeap()
	{
		case $heapSizeChoice in
			1|32m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=32m|' /data/liberty/init.d.conf ;;
			2|34m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=34m|' /data/liberty/init.d.conf ;;
			3|36m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=36m|' /data/liberty/init.d.conf ;;
			4|38m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=38m|' /data/liberty/init.d.conf ;;
			5|40m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=40m|' /data/liberty/init.d.conf ;;
			6|42m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=42m|' /data/liberty/init.d.conf ;;
			7|44m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=44m|' /data/liberty/init.d.conf ;;
			8|46m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=46m|' /data/liberty/init.d.conf ;;
			9|48m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=48m|' /data/liberty/init.d.conf ;;
			10|50m) sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=50m|' /data/liberty/init.d.conf ;;
			11|52m) sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=52m|' /data/liberty/init.d.conf ;;
			12|54m) sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=54m|' /data/liberty/init.d.conf ;;
			13|56m) sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=56m|' /data/liberty/init.d.conf ;;
			14)                                                                  ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $heapSizeChoice"    ;;
		esac
	}
	
	clearCache()
	{
		case $clearCacheChoice in
			1|1)  sed -i 's|CLEAR_CACHE=.*|CLEAR_CACHE=1|' /data/liberty/init.d.conf  ;;
			2|0)  sed -i 's|CLEAR_CACHE=.*|CLEAR_CACHE=0|' /data/liberty/init.d.conf  ;;
			3)                                                                              ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $clearCacheChoice"                ;;
		esac
	}
	
	ringDelay()
	{
		case $ringDelayChoice in
			1|2250) sed -i 's|CALL_RING_DELAY=.*|CALL_RING_DELAY=2250|' /data/liberty/init.d.conf ;;
			2|2000) sed -i 's|CALL_RING_DELAY=.*|CALL_RING_DELAY=2000|' /data/liberty/init.d.conf ;;
			3|1500) sed -i 's|CALL_RING_DELAY=.*|CALL_RING_DELAY=1500|' /data/liberty/init.d.conf ;;
			4|1000) sed -i 's|CALL_RING_DELAY=.*|CALL_RING_DELAY=1000|' /data/liberty/init.d.conf ;;
			5|750)  sed -i 's|CALL_RING_DELAY=.*|CALL_RING_DELAY=750|' /data/liberty/init.d.conf  ;;
			6|3000) sed -i 's|CALL_RING_DELAY=.*|CALL_RING_DELAY=3000|' /data/liberty/init.d.conf ;;
			7)                                                                              ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $ringDelayChoice"              ;;
		esac
	}
	
	firstBoot()
	{
		case $firstBootChoice in
			1|1)  sed -i 's|FIRST_BOOT=.*|FIRST_BOOT=1|' /data/liberty/init.d.conf  ;;
			2|0)  sed -i 's|FIRST_BOOT=.*|FIRST_BOOT=0|' /data/liberty/init.d.conf  ;;
			3)                                                                      ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $firstBootChoice"      ;;
		esac
	}
	
	fixPerm()
	{
		case $fixPermChoice in
			1|1)  sed -i 's|FIX_PERMISSIONS=.*|FIX_PERMISSIONS=1|' /data/liberty/init.d.conf  ;;
			2|0)  sed -i 's|FIX_PERMISSIONS=.*|FIX_PERMISSIONS=0|' /data/liberty/init.d.conf  ;;
			3)                                                                                ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $fixPermChoice"                  ;;
		esac
	}
	
	wifiScan()
	{
		case $wifiScanChoice in
			1|30)  sed -i 's|WIFI_SCAN_INTERVAL=.*|WIFI_SCAN_INTERVAL=30|' /data/liberty/init.d.conf  ;;
			2|45)  sed -i 's|WIFI_SCAN_INTERVAL=.*|WIFI_SCAN_INTERVAL=45|' /data/liberty/init.d.conf  ;;
			3|60)  sed -i 's|WIFI_SCAN_INTERVAL=.*|WIFI_SCAN_INTERVAL=60|' /data/liberty/init.d.conf  ;;
			4|90)  sed -i 's|WIFI_SCAN_INTERVAL=.*|WIFI_SCAN_INTERVAL=90|' /data/liberty/init.d.conf  ;;
			5|120) sed -i 's|WIFI_SCAN_INTERVAL=.*|WIFI_SCAN_INTERVAL=120|' /data/liberty/init.d.conf ;;
			6|180) sed -i 's|WIFI_SCAN_INTERVAL=.*|WIFI_SCAN_INTERVAL=180|' /data/liberty/init.d.conf ;;
			7)                                                                               ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $wifiScanChoice"                ;;
		esac
	}
	
	editProp()
	{
		case $editPropChoice in
			1|1)  sed -i 's|EDIT_PROPS=.*|EDIT_PROPS=1|' /data/liberty/init.d.conf  ;;
			2|0)  sed -i 's|EDIT_PROPS=.*|EDIT_PROPS=0|' /data/liberty/init.d.conf  ;;
			3)                                                                      ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $editPropChoice"       ;;
		esac
	}	
	freeMem()
	{
		case $freeMemChoice in
			1|25) sed -i 's|FREE_MEMORY=.*|FREE_MEMORY=25mb|' /data/liberty/init.d.conf   ;;
			2|50) sed -i 's|FREE_MEMORY=.*|FREE_MEMORY=50mb|' /data/liberty/init.d.conf   ;;
			3|75) sed -i 's|FREE_MEMORY=.*|FREE_MEMORY=75mb|' /data/liberty/init.d.conf   ;;
			4|100) sed -i 's|FREE_MEMORY=.*|FREE_MEMORY=100mb|' /data/liberty/init.d.conf ;;
			5)                                                                            ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $freeMemChoice"              ;;
		esac
	}
	
	lcdDensity()
	{
		case $lcdDensityChoice in
			1|190)	sed -i 's|LCD_DENSITY=.*|LCD_DENSITY=190|' /data/liberty/init.d.conf     ;;
			2|200)	sed -i 's|LCD_DENSITY=.*|LCD_DENSITY=200|' /data/liberty/init.d.conf     ;;
			3|210)	sed -i 's|LCD_DENSITY=.*|LCD_DENSITY=210|' /data/liberty/init.d.conf     ;;
			4|220)	sed -i 's|LCD_DENSITY=.*|LCD_DENSITY=220|' /data/liberty/init.d.conf     ;;
			5|230)	sed -i 's|LCD_DENSITY=.*|LCD_DENSITY=230|' /data/liberty/init.d.conf     ;;
			6|240)	sed -i 's|LCD_DENSITY=.*|LCD_DENSITY=240|' /data/liberty/init.d.conf     ;;
			7|250)	sed -i 's|LCD_DENSITY=.*|LCD_DENSITY=250|' /data/liberty/init.d.conf     ;;
			8|260)	sed -i 's|LCD_DENSITY=.*|LCD_DENSITY=260|' /data/liberty/init.d.conf     ;;
			9|270)	sed -i 's|LCD_DENSITY=.*|LCD_DENSITY=270|' /data/liberty/init.d.conf     ;;
			10|280)	sed -i 's|LCD_DENSITY=.*|LCD_DENSITY=280|' /data/liberty/init.d.conf     ;;
			11)                                                                     ;;
			*)		echo "${redf}Error:${cyanf} Invalid option in $lcdDensityChoice";;
		esac	
	}	
	
	maxEvents()
	{
		case $maxEventsChoice in
			1|65) sed -i 's|MAX_EVENTS_PER_SECOND=.*|MAX_EVENTS_PER_SECOND=65|' /data/liberty/init.d.conf ;;
			2|60) sed -i 's|MAX_EVENTS_PER_SECOND=.*|MAX_EVENTS_PER_SECOND=60|' /data/liberty/init.d.conf ;;
			3|55) sed -i 's|MAX_EVENTS_PER_SECOND=.*|MAX_EVENTS_PER_SECOND=55|' /data/liberty/init.d.conf ;;
			4|50) sed -i 's|MAX_EVENTS_PER_SECOND=.*|MAX_EVENTS_PER_SECOND=50|' /data/liberty/init.d.conf ;;
			5|45) sed -i 's|MAX_EVENTS_PER_SECOND=.*|MAX_EVENTS_PER_SECOND=45|' /data/liberty/init.d.conf ;;
			6)                                                                           ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $maxEventsChoice"           ;;
		esac
	}
	
	ocOnBoot()
	{
		case $ocOnBootChoice in
			1|1)  sed -i 's|OVERCLOCK_ON_BOOT=.*|OVERCLOCK_ON_BOOT=1|' /data/liberty/init.d.conf  ;;
			2|0)  sed -i 's|OVERCLOCK_ON_BOOT=.*|OVERCLOCK_ON_BOOT=0|' /data/liberty/init.d.conf  ;;
			3)                                                                                    ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $ocOnBootChoice"                     ;;
		esac
	}

	proximityDelay()
	{
	  # Black screen phone delay
		case $proximityDelayChoice in
			1|450) sed -i 's|PROXIMITY_DELAY=.*|PROXIMITY_DELAY=450|' /data/liberty/init.d.conf   ;;
			2|400) sed -i 's|PROXIMITY_DELAY=.*|PROXIMITY_DELAY=400|' /data/liberty/init.d.conf   ;; 
			3|350) sed -i 's|PROXIMITY_DELAY=.*|PROXIMITY_DELAY=350|' /data/liberty/init.d.conf   ;;
			4|300) sed -i 's|PROXIMITY_DELAY=.*|PROXIMITY_DELAY=300|' /data/liberty/init.d.conf   ;;
			5|250) sed -i 's|PROXIMITY_DELAY=.*|PROXIMITY_DELAY=250|' /data/liberty/init.d.conf   ;;
			6|200) sed -i 's|PROXIMITY_DELAY=.*|PROXIMITY_DELAY=200|' /data/liberty/init.d.conf   ;;
			7|150) sed -i 's|PROXIMITY_DELAY=.*|PROXIMITY_DELAY=150|' /data/liberty/init.d.conf   ;;
			8|100) sed -i 's|PROXIMITY_DELAY=.*|PROXIMITY_DELAY=100|' /data/liberty/init.d.conf   ;;
			9)                                                                     ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $proximityDelayChoice";;
		esac
	}
	
	recoverySafe()
	{
		case $recoverySafeChoice in
			1|1)  sed -i 's|OVERCLOCK_ON_BOOT=.*|OVERCLOCK_ON_BOOT=1|' /data/liberty/init.d.conf  ;;
			2|0)  sed -i 's|OVERCLOCK_ON_BOOT=.*|OVERCLOCK_ON_BOOT=0|' /data/liberty/init.d.conf  ;;
			3)                                                                                    ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $recoverySafeChoice"                 ;;
		esac
	}	
	
	setScaling()
	{
        echo -n What do you want for slot 1? ; read slot1
		echo -n What do you want for vsel 1? ; read vsel1
        echo -n what do you want for slot 2? ; read slot2
		echo -n What do you want for vsel 2? ; read vsel2
        echo -n what do you want for slot 3? ; read slot3
		echo -n What do you want for vsel 3? ; read vsel3
        echo -n what do you want for slot 4? ; read slot4
		echo -n What do you want for vsel 4? ; read vsel4
        echo -n ok, change it now? ; read choice
        case $choice in
	    y|Y)
		sed -ie "s|SLOT_ONE=.*|SLOT_ONE=${slot1}|" -e "s|SLOT_TWO=.*|SLOT_TWO=${slot2}|" -e "s|SLOT_THREE=.*|SLOT_THREE=${slot3}|" -e "s|SLOT_FOUR=.*|SLOT_FOUR=${slot4}|" -e "s|VSEL_ONE=.*|VSEL_ONE=${vsel1}|" -e "s|VSEL_TWO=.*|VSEL_TWO=${vsel2}|" -e "s|VSEL_THREE=.*|VSEL_THREE=${vsel3}|" -e "s|VSEL_FOUR=.*|VSEL_FOUR=${vsel4}|" /data/liberty/init.d.conf ;;
        esac
	}
		
	zipalignSystem()	
	{
		case $zipalignSystemChoice in
			1|1)  sed -i 's|ZIPALIGN_SYSTEM_APPS=.*|ZIPALIGN_SYSTEM_APPS=1|' /data/liberty/init.d.conf  ;;
			2|0)  sed -i 's|ZIPALIGN_SYSTEM_APPS=.*|ZIPALIGN_SYSTEM_APPS=0|' /data/liberty/init.d.conf  ;;
			3)                                                                              ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $zipalignSystemChoice"                ;;
		esac
	}

	zipalignData()
	{
		case $zipalignDataChoice in
			1|1)  sed -i 's|ZIPALIGN_DATA_APPS=.*|ZIPALIGN_DATA_APPS=1|' /data/liberty/init.d.conf  ;;
			2|0)  sed -i 's|ZIPALIGN_DATA_APPS=.*|ZIPALIGN_DATA_APPS=0|' /data/liberty/init.d.conf  ;;
			3)                                                                                      ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $zipalignDataChoice"                   ;;
		esac
	}

	case $1 in
		""|-m|--menu)
			EXIT_SETINIT=0
			while $BB test $EXIT_SETINIT -ne 1; do
				echo "==================================="
				echo " 1  Change Dalvik VM Heap Size"
				echo " 2  Enable/Disable Clear cache"
				echo " 3  Change Call Ring Delay"
				echo " 4  Enable/Disable firstboot script"
				echo " 5  Enable/Disable fix permissions on boot"
				echo " 6  Change WiFi scan period"
				echo " 7  Enable/Disable Edit Props on boot"
				echo " 8  Set minimum free memory"
				echo " 9  Change LCD Density"
				echo " 10 Enable better scrolling speed"
				echo " 11 Enable Overclock On Boot"
				echo " 12 Black screen phone delay"
				echo " 13 Enable/Disable CWM on Each boot" 
				echo " 14 Adjust Scaling Overclock **BE CAREFUL!!**"
				echo " 15 Zipalign System apps on Boot"
				echo " 16 Zipalign Data apps on Boot"
				echo " 17 Exit this menu"
				echo "==================================="
				echo -n "${redf}Please choose a number: ${blackf}"
				read setInitChoice
				case $setInitChoice in
					1) 
					    . /data/liberty/init.d.conf
						echo "==================================="
						echo " Your current value is $DALVIK_VM_HEAP"
						echo " 1   Set VM Heap Size to 32m"
						echo " 2   Set VM Heap Size to 34m"
						echo " 3   Set VM Heap Size to 36m"
						echo " 4   Set VM Heap Size to 38m"
						echo " 5   Set VM Heap Size to 40m"
						echo " 6   Set VM Heap Size to 42m"
						echo " 7   Set VM Heap Size to 44m"
						echo " 8   Set VM Heap Size to 46m"
						echo " 9   Set VM Heap Size to 48m"
						echo " 10  Set VM Heap Size to 50m"
						echo " 11  Set VM Heap Size to 52m"
						echo " 12  Set VM Heap Size to 54m"
						echo " 13  Set VM Heap Size to 56m"
						echo " 14  Exit this menu"
						echo "==================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read heapSizeChoice
						vmHeap
					;;
					2) 
					    . /data/liberty/init.d.conf
						echo "============================================="
						echo " Your current value is $CLEAR_CACHE"
						echo " 1  Enable Clear Cache On boot"
						echo " 2  Disable Clear Cache On boot"
						echo " 3  Exit this menu"
						echo "============================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read clearCacheChoice
						clearCache
					;;
					3) 
					    . /data/liberty/init.d.conf
						echo "==============================="
						echo " Your current value is $CALL_RING_DELAY"
						echo " 1  Reduce ring delay by 1/4"
						echo " 2  Reduce ring delay by 1/3"
						echo " 3  Reduce ring delay in half"
						echo " 4  Reduce ring delay by 2/3"
						echo " 5  Reduce ring delay by 3/4"
						echo " 6  Set to default delay time"
						echo " 7  Exit this menu"
						echo "==============================="
						echo -n "${redf}Please choose a number: ${blackf}"; read ringDelayChoice
						ringDelay 
					;;
					4) 
					    . /data/liberty/init.d.conf
						echo "============================================="
						echo " Your current value is $FIRST_BOOT"
						echo " 1  Enable First Boot script"
						echo " 2  Disable First Boot script"
						echo " 3  Exit this menu"
						echo "============================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read firstBootChoice
						firstBoot
					;;
					5) 
					    . /data/liberty/init.d.conf
						echo "============================================="
						echo " Your current value is $FIX_PERMISSIONS"
						echo " 1  Enable Fix Permissions on boot"
						echo " 2  Disable Fix Permissions on boot"
						echo " 3  Exit this menu"
						echo "============================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read fixPermChoice
						fixPerm
					;;
					6)
					    . /data/liberty/init.d.conf
						echo "============================================="
						echo " Your current value is $WIFI_SCAN_INTERVAL"
						echo " 1  Change Wifi scan time to 30"
						echo " 2  Change Wifi scan time to 45"
						echo " 3  Change Wifi scan time to 60"
                        echo " 4  Change Wifi scan time to 90"
						echo " 5  Change Wifi scan time to 120"
						echo " 6  Change Wifi scan time to 180"
						echo " 7  Exit this menu"
						echo "============================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read wifiScanChoice
						wifiScan	
					;;
					7) 
					    . /data/liberty/init.d.conf
						echo "============================================="
						echo " Your current value is $EDIT_PROPS"
						echo " 1  Enable Edit Props On boot"
						echo " 2  Disable Edit Props On boot"
						echo " 3  Exit this menu"
						echo "============================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read editPropChoice
						editProp
					;;	
					8) 
					    . /data/liberty/init.d.conf
						echo "==========================================================="
						echo " Your current value is $FREE_MEMORY"
						echo " 1  Set minimum free memory to 25mb"
						echo " 2  Set minimum free memory to 50mb"
						echo " 3  Set minimum free memory to 75mb"
						echo " 4  Set minimum free memory to 100mb"
						echo " 5  Exit this menu"
						echo "==========================================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read freeMemChoice
						freeMem
					;;		
					9)
					    . /data/liberty/init.d.conf
						echo "================================"
						echo " Your current value is $LCD_DENSITY"
						echo " 1  Set LCD Density to 190"
						echo " 2  Set LCD Density to 200"
						echo " 3  Set LCD Density to 210"
						echo " 4  Set LCD Density to 220"
						echo " 5  Set LCD Density to 230"
						echo " 6  Set LCD Density to 240"
						echo " 7  Set LCD Density to 250"
						echo " 8  Set LCD Density to 260"
						echo " 9  Set LCD Density to 270"
						echo " 10 Set LCD Density to 280"
						echo " 11 Exit this menu"
						echo "================================"
						echo -n "${redf}Please choose a number: ${blackf}"; read lcdDensityChoice
						lcdDensity
					;;					
					10) 
					    . /data/liberty/init.d.conf
						echo "==========================================================="
						echo " ** The lower the value the faster the scrolling speed **"
						echo "Your current value is $MAX_EVENTS_PER_SECOND"
						echo 
						echo " 1  Set max events per second to 65"
						echo " 2  Set max events per second to 60"
						echo " 3  Set max events per second to 55"
						echo " 4  Set max events per second to 50"
						echo " 5  Set max events per second to 45"
						echo " 6  Exit this menu"
						echo "==========================================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read maxEventsChoice
						maxEvents
					;;
					11) 
					    . /data/liberty/init.d.conf
						echo "============================================="
						echo " Your current value is $OVERCLOCK_ON_BOOT"
						echo " 1  Enable Overclock On boot"
						echo " 2  Disable Overclock On boot"
						echo " 3  Exit this menu"
						echo "============================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read ocOnBootChoice
						ocOnBoot
					;;						
					12)
					    . /data/liberty/init.d.conf
						echo "======================================================="
						echo " Your current value is $PROXIMITY_DELAY"
						echo " ** The lower the value the shorter the delay **"
						echo " 1 Set proximity delay to 450"
						echo " 2 Set proximity delay to 400"
						echo " 3 Set proximity delay to 350"
						echo " 4 Set proximity delay to 300"
						echo " 5 Set proximity delay to 250"
						echo " 6 Set proximity delay to 200"
						echo " 7 Set proximity delay to 150"
						echo " 8 Set proximity delay to 100"
						echo " 9  Exit this menu"
						echo "======================================================"
						echo -n "${redf}Please choose a number: ${blackf}"; read proximityDelayChoice
						proximityDelay
					;;
					13) 
					    . /data/liberty/init.d.conf
						echo "============================================="
						echo " Your current value is $RECOVERY_SAFEMODE"
						echo " 1  Enable CWM On boot"
						echo " 2  Disable CWM On boot"
						echo " 3  Exit this menu"
						echo "============================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read recoverySafeChoice
						recoverySafe
					;;	
					14)
					    . /data/liberty/init.d.conf
					    echo "Your current scaling setup is $SLOT_ONE $VSEL_ONE $SLOT_TWO $VSEL_TWO $SLOT_THREE $VSEL_THREE $SLOT_FOUR $VSEL_FOUR"
					    setScaling 
					;;
					15) 
					    . /data/liberty/init.d.conf
						echo "============================================="
						echo " Your current value is $ZIPALIGN_SYSTEM_APPS"
						echo " 1  Zipalign System Apps On boot"
						echo " 2  Disable Zipalign System On boot"
						echo " 3  Exit this menu"
						echo "============================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read zipalignSystemChoice
						zipalignSystem
					;;	
					16) 
					    . /data/liberty/init.d.conf
						echo "============================================="
						echo " Your current value is $ZIPALIGN_DATA_APPS"
						echo " 1  Zipalign Data Apps On boot"
						echo " 2  Disable Zipalign Data On boot"
						echo " 3  Exit this menu"
						echo "============================================="
						echo -n "${redf}Please choose a number: ${blackf}"; read zipalignDataChoice
						zipalignData
					;;					
					17)
						EXIT_SETINIT=1
					;;
					*)
						echo "${redf}Error:${cyanf} Invalid option in $setInitChoice"
					;;
				esac
			done
		;;
		vmheap)
			heapSizeChoice=$2
			vmHeap
		;;
		clearcache)
			clearCacheChoice=$2
			ClearCache
		;;
		ringdelay)
			ringDelayChoice=$2
			ringDelay
		;;
		firstboot)
		    firstBootChoice=$2
			firstBoot
		;;
        fixperm)
            fixPermChoice=$2
            fixPerm
		;;	
		wifiscan)
		    wifiScanChoice=$2
			wifiScan
		;;	
		editProp)
		    editPropChoice=$2
			editprop
		;;
		freeMem)
		    freeMemChoice=$2
			freeMem
		;;	
		lcddensity)
			lcdDensityChoice=$2
			lcdDensity
		;;		
		maxevents)
			maxEventsChoice=$2
			maxEvents
		;;
		oconboot)
		    ocOnBootChoice=$2
			ocOnBoot
		;;	
		proximitydelay)
			proximityDelayChoice=$2
			proximityDelay
		;;
		recoverysafe)
 		    recoverySafeChoice=$2
			recoverySafe
		;;
		setscaling)
		    setScaling
		;;
		zipalignsystem)
		    zipalignSystemChoice=$2
			zipalignSystem
		;;
		zipaligndata)
		    zipalignDataChoice=$2
			zipalignData
		;;
		maxpoints)
		    maxPointsChoice=$2
			maxPoints
		;;	
	esac
}

_slim()
{
	SLIM_DIR=/mnt/sdcard/slim
	
	slimUsage()
	{
		echo "Usage: slim [-l] [-s]"
		echo 
		echo "Options:"
		echo "    -l | --list    Creates a list of your apps and media"
		echo "    -s | --slim    Removes unwanted specified files"
		echo "    -h | --help    This help"
		echo 
		echo "Instructions to remove files:"
		echo "  Run slim -l"
		echo "  Open $EXTERNAL_DIR/apps.list and $EXTERNAL_DIR/media.list"
		echo "  Remove the '#' sign infront of unwanted files"
		echo "  Run slim -s"
	}
	
	listFiles()
	{
		$BB mkdir -p $EXTERNAL_DIR/slim
		echo > $EXTERNAL_DIR/apps.list
		$BB find /system/app -iname *.apk -exec echo "#{}" >> $EXTERNAL_DIR/slim/apps.list ';'
		echo  > $EXTERNAL_DIR/media.list
		$BB find /system/media -iname *.ogg -exec echo "#{}" >> $EXTERNAL_DIR/slim/media.list ';'	
		ECHO -l "Created slim files."
	}
	
	slimApps()
	{
		if $BB test ! -e $EXTERNAL_DIR/apps.list; then
			ECHO -l "${redf}Error:${cyanf} No list found to slim apps."
			return
		fi
		
		if $BB test -z "`$BB cat $EXTERNAL_DIR/slim/apps.list | $BB sed 's|\#.*||g'`"; then
			ECHO -l "No apps have been sepecified to remove."
			return
		fi
		
		ECHO -l "Sliming your apps ... "
		ECHO -l
		
		for apk in `$BB cat $EXTERNAL_DIR/slim/apps.list | $BB sed 's|\#.*||g'`; do
			if $BB test -e $apk; then
				package=`pm list packages -f | grep $apk | sed 's|.*apk=||'`
				$BB rm -f $apk
				pm uninstall $package > /dev/null				
			else
				ECHO -l "Can\`t remove $apk (no such file found)."
			fi
		done
	}
	
	slimMedia()
	{
		if $BB test ! -e $EXTERNAL_DIR/slim/media.list; then
			ECHO -l "${redf}Error:${cyanf} No list found to slim media."
			return
		fi
		
		if $BB test -z "`$BB cat $EXTERNAL_DIR/media.list | $BB sed 's|\#.*||g'`"; then
			ECHO -l "No media has been sepecified to remove."
			return
		else
			ECHO -l "Sliming your media ... "
			ECHO -l
		fi
		
		for ogg in `$BB cat $EXTERNAL_DIR/slim/media.list | $BB sed 's|\#.*||g'`; do
			if $BB test -e $ogg; then
				ECHO -l -n "Removing `$BB basename $ogg` ... "
				$BB rm -f $ogg
				ECHO -l "done."
			else
				ECHO -l "Can\`t remove $ogg (no such file found)."
			fi
		done
	}
	
	case $1 in
		-l|--list) listFiles          ;;
		-s|--slim) slimApps;slimMedia ;;
		*)         slimUsage          ;;
	esac
}

_sound()
{
	soundUsage()
	{
		echo "Usage: sound [unlock|lock]"
		echo 
		echo "Options:"
		echo "    lock    Changes lock screen lock notification sound"
		echo "    unlock  Changes unlock screen lock notification sound"
		echo 
		echo "Both options will list available sounds that you can"
		echo "choose for your lock screen (lock/unlock) notification"
		echo "sound. Simply type the name of the sound and it will"
		echo "change after you reboot your device."
	}

	lockScreenSound()
	{
		if $BB test -z $2; then
			SOUNDS_DIR=/system/media/audio
		elif $BB test -d $2; then
			SOUNDS_DIR="$2"	# User can enter the path to .ogg files as the 2nd argument.
		fi
		$BB find $SOUNDS_DIR -name *.ogg -type f -exec sh -c 'echo "`$BB basename {}`"' ';'
		ECHO -l
		ECHO -l -n "Type the file name for your $1 sound: "; read soundChoice
		ECHO -lo "$soundChoice"
		
		# Check if file exists:
		if $BB test -z $(ls `$BB find $SOUNDS_DIR -name *.ogg -type f` | $BB grep -i $soundChoice); then
			ECHO -l "${redf}Error:${cyanf} $soundChoice not found."
			return
		fi
		$BB ls `$BB find $SOUNDS_DIR -name *.ogg -type f` | $BB grep -i $soundChoice | while read ogg	# Partial name match
		do
			$BB cp -f $ogg /system/media/audio/ui/$1.ogg
			ECHO -l
			ECHO -l "`$BB basename $ogg` is now used as your $1 sound."
			ECHO -l
		done
		promtReboot msg2
	}

	case $1 in
		lock) lockScreenSound Lock $2;;
		unlock) lockScreenSound Unlock $2;;
		*) soundUsage;;
	esac
}

_switch()
{
	switchUsage()
	{
		echo "Usage: switch [lwp|ba]"
		echo 
		echo "Switches commonly changed files."
		echo "Files must be on the root of the sdcard."
		echo "You can switch any file with a file already"
		echo "in /system by doing \"switch file_name\""
	}		
	
	switchBootAnimation()
	{
		if $BB test -e /mnt/sdcard/bootanimation.zip; then
			ECHO -l -n "Removing old boot animation ... "
			$BB find /data/local /system/media -name bootanimation.zip -exec $BB rm -f {} ';'
			ECHO -l "done."
			echo -n "Installing bootanimation from /sdcard ... "
			$BB cp -f /mnt/sdcard/bootanimation.zip /data/local
			$BB chmod 0655 /data/local/bootanimation.zip
			ECHO -l "done."
		else
			ECHO -l "${redf}Error:${cyanf} bootanimation.zip not found on the root of your sdcard."
		fi
	}
	
	switchLiveWallpaper()
	{
		if $BB test -e /mnt/sdcard/LiveWallpapers.apk; then
			ECHO -l -n "Installing Live Wallpaper ... "
			$BB cp -f /mnt/sdcard/LiveWallpaper.apk /system/app
			ECHO -l "done."
		else
			ECHO -l "${redf}Error:${cyanf} LiveWallpapers.apk not found on the root of your sdcard."
		fi
	}
	
	switchAnyFile()
	{
		# Start file checks:
		if $BB test ! -e /mnt/sdcard/$1; then
			ECHO -l "${redf}Error:${cyanf} $1 not found on the root of your sdcard."
			return
		elif $BB test -z "`$BB find /system -type f -print | grep -i $1`"; then
			ECHO -l "${redf}Error:${cyanf} $1 not found in /system to switch."
			return
		elif $BB test `$BB find /system -type f -iname $1 | $BB wc -l` -ne 1; then
			ECHO -l "${redf}Error:${cyanf} Failed to switch $1 becuase of multiple files."
			return
		fi
		
		SWITCH=`$BB find /system -type f -iname $1 -print`
		ECHO -l -n "Switching /sdcard/$1 with $SWITCH ... "
		# Make a backup of what is being switched.
		$BB mkdir -p $EXTERNAL_DIR/switch_backup
		$BB find /system -type f -iname $1 -exec $BB cp {} $EXTERNAL_DIR/switch_backup ';'
		$BB cp -f /mnt/sdcard/$1 $SWITCH
		ECHO -l "done."
	}
	
	if $BB test $# == 0 -o $1 == "-help"; then
		switchUsage
		return
	fi
	
	case $1 in
		ba|--bootanimation)
			switchBootAnimation
		;;
		lwp|--LiveWallpaper)
			switchLiveWallpaper
		;;
		*)
			switchAnyFile $1
		;;
	esac
}

_symlink()
{
	symlinkUsage()
	{
		echo "Usage: symlink [-rt|-bb]"
		echo 
		echo "options:"
		echo "      -rt | roottools   symlinks roottools functions"
		echo "      -bb | busybox     symlinks busybox applets"
	}
	
	symlinkRoottools()
	{
		ECHO -l "symlinking roottools functions ..."
		ECHO -l
		
		for script in ads allinone apploc backup bootani cache camsound compcache chglog \
		    donate exe fixperms freemem install_zip load pulldown_text rb restore \
			rmapk setcpu setprops slim sound switch symlink sysro sysrw usb zipalign_apks
		do
			if $BB test -h /system/xbin/$script -o -e /system/xbin/$script; then
				$BB rm -f /system/xbin/$script
			fi
			$BB ln -s /system/xbin/$SCRIPT_NAME /system/xbin/$script
			ECHO -l "Symlinked: $script"
		done
	}
	
	symlinkBusybox()
	{
		ECHO -l "symlinking busybox applets ..."
		ECHO -l
		
		if $BB test -z "$($BB grep "\-\-install" $BB)"; then
			for applet in `$BB | $BB grep , | $BB grep -vi busybox | $BB grep -v -i copyright | $BB sed 's|,||g'`; do
				if $BB test -e $($BB dirname $BB)/$applet -o -h $($BB dirname $BB)/$applet; then
					$BB rm -f $($BB dirname $BB)/$applet
				fi
				$BB ln -s $BB $($BB dirname $BB)/$applet
				ECHO -l "Symlinked: $applet"
			done
		else
			$BB --install $($BB dirname $BB)
		fi
	}
	
	case $1 in
		-rt|roottools) symlinkRoottools ;;
		-bb|busybox)  symlinkBusybox    ;;
		*) symlinkUsage                 ;;
	esac
}

_sysro()
{
	if $BB test $# -gt 0; then
		echo "Usage: sysro"
		echo 
		echo "Mounts the /system partition read-only"
	fi
	
	$BB mount -o remount,ro -t yaffs2 `$BB grep " /system " "/proc/mounts" | $BB cut -d ' ' -f1` /system > /dev/nul 2>&1
	ECHO -l "System mounted read-only"
	sync
}

_sysrw()
{
	if $BB test $# -gt 0; then
		echo "Usage: sysrw"
		echo 
		echo "Mounts the /system partition read/write"
	fi
	
	$BB mount -o remount,rw -t yaffs2 `$BB grep " /system " "/proc/mounts" | $BB cut -d ' ' -f1` /system > /dev/nul 2>&1
	ECHO -l "System mounted read/write"
}

_usb()
{
	usbUsage()
	{
		echo "Usage: usb [-e|-d]"
		echo 
		echo "options:"
		echo "   -e   enables usb mass storage"
		echo "   -d   disables usb mass storage"
	}
	
	case $1 in
		-e|--enable|on)
			echo `mount | grep -m 1 /dev/block/vold | awk '{print $1}'` > /sys/devices/platform/usb_mass_storage/lun0/file
			ECHO -l "USB Mass Storage Enabled"
		;;
		-d|--disable|off)
			echo "" > /sys/devices/platform/usb_mass_storage/lun0/file
			ECHO -l "USB Mass Storage Disabled"
		;;
		-h|help|-help)
			usbUsage
		;;
		*)
			# Toggle on/off:
			if $BB test -z "$($BB mount | $BB grep /sdcard)"; then
				_usb -d
			else
				_usb -e
			fi
		;;
	esac
}

_zipalign_apks()
{	
	zipalign_apksUsage()
	{
		echo " Usage: zipalign_apks [-a|-sd|<destination>]"
		echo 
		echo " options:"
		echo 
		echo "    -a  | --all     Zipaligns all apks in /data and /system"
		echo "                    ^ Runs as default with no options."
		echo "    -m  | --menu    Prints menu with options"
		echo "    -sd | --sdcard  Zipaligns all apks in /sdcard"
		echo "    <destination>   Zipaligns all apks in users choice"
		echo "    -h  | --help    This help"
		echo 
		echo "    Always specify options as separate words" 
		echo "    e.g. -r -c instead of -rc. Its required!"
		echo "    To zipalign apks in your own destination"
		echo "    of choice just type the directory path after"
		echo "    zipalign_apks."
		echo "    Example: zipalign_apks /sdcard/apps"
	}
	
	zipalignApksMenu()
	{
		echo "============================================="
		echo " 1  Zipalign all apks in /system and /data"
		echo " 2  Enter directory to zipalign apks in"
		echo " 3  Exit this menu"
		echo "============================================="
		echo -n "${redf}Please choose a number: ${blackf}"; read zipalignChoice
		case $zipalignChoice in
			1)
				_zipalign_apks --all
			;;
			2)
				echo "================================================="
				echo " Please choose a destination to ZipAlign apks"
				echo " Example 1: /sdcard/my_apps"
				echo " Example 2: /system/app"
				echo "================================================="
				echo -n "Please enter path to apks: "; read zipchoice
				_zipalign_apks "$zipchoice"
			;;
			3)
			
			;;
			*)
				echo "${redf}Error:${cyanf} Invalid option in $zipalignChoice"
			;;
		esac
	}
	
	zipalignApks()
	{
		echo 
		echo "**********************************"
		echo "*** ${yellowf}Zipaligning apks ...${blackf}"
		echo "**********************************"
		echo 
	
		if $BB test -z "$($BB mount | $BB grep /sdcard)"; then
			TMP_ZIPALIGN_DIR=/data/local/zipalign_apks/tmp
		else
			TMP_ZIPALIGN_DIR=/mnt/sdcard/zipalign_apks/tmp
		fi
		
		if $BB test ! -e /system/bin/zipalign -a ! -e /system/xbin/zipalign; then
			ECHO -l -n "Downloading zipalign binary ... "
			$BB wget -q $ZIPALIGN_BINARY -O /system/xbin/zipalign
			$BB chmod 0755 /system/xbin/zipalign
			ECHO -l "done."
		fi
		
		APK_SUM=`$BB find $1 -name *.apk | $BB wc -l`
		APK=0
		APKS_ZIPALIGNED=0
		START=$($BB date +%s)
		stagefright -a -o /system/media/audible/zipstarted.mp3
		
		$BB mkdir -p $TMP_ZIPALIGN_DIR
		
		for apk in `$BB find $1 -name *.apk`; do
			
			APK=$(($APK+1))
			echo -n "${yellowf}($APK of $APK_SUM)${blackf} "
			zipalign -c 4 $apk
			ZIPCHECK=$?
			
			case $ZIPCHECK in
				1)
					ECHO -l -n "ZipAligning: $($BB basename $apk) ... "
					zipalign -f 4 $apk $TMP_ZIPALIGN_DIR/`$BB basename $apk`
					if $BB test -e $TMP_ZIPALIGN_DIR/`$BB basename $apk`; then
						$BB cp -f $TMP_ZIPALIGN_DIR/`$BB basename $apk` $apk
						$BB rm -f $TMP_ZIPALIGN_DIR/`$BB basename $apk`
						ECHO -l "done."
						APKS_ZIPALIGNED=$(($APKS_ZIPALIGNED+1))
					else
						ECHO -l "failed!"
					fi
				;;
				*)
					ECHO -l "Skipped: `$BB basename $apk` (ZipAlign already completed)"
				;;
			esac
		done
		
		STOP=$($BB date +%s)
		
		stagefright -a -o /system/media/audible/zipfinished.mp3
		
		echo 
		echo "$APKS_ZIPALIGNED out of $APK_SUM apks were zipaligned."
		echo "Zipalign completed at "`$BB  date +"%m-%d-%Y %H:%M:%S"`""
		echo "zipalign_apks runtime: "`taskRuntime`""
		echo 
		$BB rm -R $TMP_ZIPALIGN_DIR
		if $BB test $APKS_ZIPALIGNED -gt 0; then
			promtReboot msg1
		fi
	}
	
	case "$1" in
		""|-a|--all)
			zipalignApks "/data /system"
		;;
		-m|--menu)
			zipalignApksMenu
		;;
		-sd|--sdcard)
			checkSD
			zipalignApks "/mnt/sdcard /sdcard"
		;;
		-h|-help|--help)
			zipalign_apksUsage
		;;
		*)	# Zipalign apks in users choice:
			if $BB test -d $1; then
				zipalignStart
				zipalignApks "$1"
			else
				zipalign_apksUsage
			fi
		;;
	esac
}
mloadFonts()
		{
			FONT_DIR=$EXTERNAL_DIR/goodies/fonts
			$BB mkdir -p $FONT_DIR/$1
			if $BB test `$BB find $FONT_DIR/$1 -iname *.ttf | $BB wc -l` -eq 0; then
				ECHO -l "Downloading fonts ... "
				$BB wget $FONT_URL/$1.zip -O $FONT_DIR/$1/$1.zip
				$BB unzip -o $FONT_DIR/$1/$1.zip -d $FONT_DIR/$1
				$BB rm -f $FONT_DIR/$1/$1.zip
			fi
			$BB find $FONT_DIR/$1 -iname *.ttf -print | while read ttf
			do
				$BB cp -f $ttf /system/fonts
			done
			ECHO -l "$1 fonts have been installed."
			promtReboot msg2
		}


mloadBootLogos()
		{
			BOOTLOGO_DIR=$EXTERNAL_DIR/goodies/bootlogos
			if $BB test ! -e $BOOTLOGO_DIR/$1/update.zip; then
				ECHO -l "Downloading bootlogo ..."
				$BB mkdir -p $BOOTLOGO_DIR/$1
				$BB wget $BOOTLOGO_URL/$1/update.zip -O $BOOTLOGO_DIR/$1/update.zip
			fi
			ECHO -l "done."
			ECHO -l -n "Switching bootlogo ... "
			rm -f /data/.bootmenu_bypass && echo recovery > /cache/recovery/bootmode.conf && echo "install_zip("$BOOTLOGO_DIR/$1/update.zip")" > /cache/recovery/extendedcommand && reboot
		}
mloadClock()
		{
		    CLOCK_DIR=/system/etc/clock	
		    sysrw
		    cd $CLOCK_DIR/$1
		    zip -o -9 /system/app/SystemUI.apk res/layout/*.xml
            killall system_server
		}
mloadDns()
		{
	    		DNS_URL=http://santiemanuel.grupoandroid.com/stuff/dns
			DNS_DIR=/system/etc
			$BB wget $DNS_URL/$1 -O $DNS_DIR/resolv.conf
			chmod 644 $DNS_DIR/resolv.conf
			sleep 1
		}
mloadKeypad()
		{
			FILES_DIR=$EXTERNAL_DIR/keypads
			KEYCHARS=/system/usr/keychars
			KEYLAYOUT=/system/usr/keylayout
			$BB cp -f $FILES_DIR/$1.kl $KEYLAYOUT/qwerty.kl
			$BB cp -f $FILES_DIR/$1.kl $KEYLAYOUT/sholes-keypad.kl
			$BB cp -f $FILES_DIR/$1.kl $KEYLAYOUT/umts_milestone2-keypad.kl
			$BB cp -f $FILES_DIR/$1.kl $KEYLAYOUT/qtouch-touchscreen.kl
			$BB cp -f $FILES_DIR/$1.kcm.bin $KEYCHARS/qwerty.kcm.bin
            		gingerkeys hotreboot
		}


mloadAnim()
		{
			APP_DIR=$EXTERNAL_DIR/goodies/metamorph
			ECHO -l "Analyzing anim.zip ..."
			$BB mkdir -p $APP_DIR/reanim/res
			$BB wget $ANIM_URL/$1.zip -O $APP_DIR/reanim/res/anim.zip
			sh /system/xbin/mm.sh
		}

mloadTheme()
		{
			THEME_DIR=$EXTERNAL_DIR/goodies/themes
			if $BB test ! -e $THEME_DIR/$1/update.zip; then
				ECHO -l "Downloading theme ..."
				$BB mkdir -p $THEME_DIR/$1
				$BB wget $THEME_URL/$1/update.zip -O $THEME_DIR/$1/update.zip
			fi
			ECHO -l "done."
			ECHO -l -n "Installing theme ... "
            echo "install_zip SDCARD:/roottools/goodies/themes/$1/update.zip" > /cache/recovery/extendedcommand
			> /data/.recovery_mode
			_rb prepareShutdown
			ECHO -l "Rebooting to apply theme."
			sleep 5
			reboot
		}


mloadBootsound()
		{
			BOOTSOUND_DIR=$EXTERNAL_DIR/goodies/bootsound
			if $BB test ! -e $BOOTSOUND_DIR/$1.mp3; then
				ECHO -l "Downloading bootsound ..."
				$BB mkdir -p $BOOTSOUND_DIR
				$BB wget $BOOTSOUND_URL/$1.mp3 -O $BOOTSOUND_DIR/$1.mp3
			fi
			ECHO -l -n "Removing old bootsound ... "
			$BB find /system/media /data/local -name android_audio.mp3 -exec $BB rm -f {} ';'
			ECHO -l "done."
			ECHO -l -n "Installing boot sound ... "
			$BB cp -f $BOOTSOUND_DIR/$1.mp3 /system/media/android_audio.mp3
			$BB chmod 0644 /system/media/android_audio.mp3
			ECHO -l "done."
			ECHO -l "Reboot to listen to the new sound, it's loud ;)."
			_rb reboot
		}

mloadBootAnimation()
		{
			BOOTANIMATION_DIR=$EXTERNAL_DIR/goodies/bootanimations
			if $BB test ! -e $BOOTANIMATION_DIR/$1/bootanimation.zip; then
				ECHO -l "Downloading bootanimation ..."
				$BB mkdir -p $BOOTANIMATION_DIR/$1
				$BB wget $BOOTANIMATION_URL/$1/bootanimation.zip -O $BOOTANIMATION_DIR/$1/bootanimation.zip
			fi
			ECHO -l -n "Removing old bootanimation.zip ... "
			$BB find /system/media /data/local -name bootanimation.zip -exec $BB rm -f {} ';'
			ECHO -l "done."
			ECHO -l -n "Installing bootanimation.zip ... "
			$BB cp -f $BOOTANIMATION_DIR/$1/bootanimation.zip /data/local
			$BB chmod 0655 /data/local/bootanimation.zip
			ECHO -l "done."
			ECHO -l "Rebooting to show off the new bootanimation."
			_rb reboot
		}

mremoveAnyApp()
	{
		if $BB test -z "`$BB ls /system/app | $BB grep -i "$1"`" > /dev/null 2>&1; then
			ECHO -l "${redf}Error:${cyanf} $1 not found in /system/app!"
			ECHO -l
			rmapkUsage
		else
			for apk in `ls /system/app | $BB grep -i "$1"`; do	# Find the app with any partial name match.
				packageName=$(pm list packages -f | $BB grep $apk | $BB sed "s|.*$apk=||g")	# get the apps package name for pm uninstall
				if $BB test $PROMPTREMOVE -eq 1; then
					ECHO -l -n "${redf}Continue to remove and uninstall `$BB basename $apk`? (y/n): ${blackf}"
					read uninstallChoice
					case $uninstallChoice in
						y|Y)
							ECHO -l -n "Removing and uninstalling `$BB basename $apk` ... "
							$BB rm -f /system/app/$apk
							if $BB test `pm uninstall $packageName 2>/dev/null` == "Success"; then
								ECHO -l "done."
							else
								ECHO -l "${redf}Uninstall failed for `$BB basename $apk`!${blackf}"
							fi
						;;
					esac
				else
					ECHO -l -n "Removing and uninstalling `$BB basename $apk` ... "
					$BB rm -f /system/app/$apk
					if $BB test `pm uninstall $packageName 2>/dev/null` == "Success"; then
						ECHO -l "done."
					else
						ECHO -l "Uninstall failed for `$BB basename $apk`!"
					fi
				fi
			done
		fi
	}
mvmHeap()
	{
		case $1 in
			1|32m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=32m|' /data/liberty/init.d.conf ;;
			2|34m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=34m|' /data/liberty/init.d.conf ;;
			3|36m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=36m|' /data/liberty/init.d.conf ;;
			4|38m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=38m|' /data/liberty/init.d.conf ;;
			5|40m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=40m|' /data/liberty/init.d.conf ;;
			6|42m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=42m|' /data/liberty/init.d.conf ;;
			7|44m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=44m|' /data/liberty/init.d.conf ;;
			8|46m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=46m|' /data/liberty/init.d.conf ;;
			9|48m)  sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=48m|' /data/liberty/init.d.conf ;;
			10|50m) sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=50m|' /data/liberty/init.d.conf ;;
			11|52m) sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=52m|' /data/liberty/init.d.conf ;;
			12|54m) sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=54m|' /data/liberty/init.d.conf ;;
			13|56m) sed -i 's|DALVIK_VM_HEAP=.*|DALVIK_VM_HEAP=56m|' /data/liberty/init.d.conf ;;
			14)                                                                  ;;
			*) echo "${redf}Error:${cyanf} Invalid option in $1"    ;;
		esac
	}
rsetscaling()
	{

		sed -ie "s|SLOT_ONE=.*|SLOT_ONE=$1|" -e "s|SLOT_TWO=.*|SLOT_TWO=$2|" -e "s|SLOT_THREE=.*|SLOT_THREE=$3|" -e "s|SLOT_FOUR=.*|SLOT_FOUR=$4|" -e "s|VSEL_ONE=.*|VSEL_ONE=$5|" -e "s|VSEL_TWO=.*|VSEL_TWO=$6|" -e "s|VSEL_THREE=.*|VSEL_THREE=$7|" -e "s|VSEL_FOUR=.*|VSEL_FOUR=$8|" /data/liberty/init.d.conf 
	}
cpuInfo()
	{
	AVAILABLE_FREQ="/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies"
	AVAILABLE_GOVERNORS="/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors"
		echo -e " - CPU Info -"
		echo -e " Maximum Frequency Applied: \n "`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq`""
		echo -e "-\n"
		echo -e " Maximum Frequency Available: \n "`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq`""
		echo -e "-\n"
		echo -e " Minimum Frequency Applied: \n "`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq`""
		echo -e "-\n"
		echo -e " Minimum Frequency Available: \n "`cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq`""
		echo -e "-\n"
		echo -e " Current Frequency Speed: \n "`cat /proc/cpuinfo | $BB grep BogoMIPS | $BB awk '{print $3}'`""
		echo -e "-\n"
		echo -e " Scaling Governor Applied: \n "`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`""
		echo -e "-\n"
		echo -e " Available Frequencies: \n"`cat $AVAILABLE_FREQ`""
		echo -e "-\n"
		echo -e " Scaling Governors Available: \n "`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors`""
		echo -e "-\n"
		echo -e " Up Threshold Applied: \n "`cat /sys/devices/system/cpu/cpu0/cpufreq/ondemand/up_threshold`""
		echo -e "-\n"
		echo -e " Sampling Rate Applied: \n "`cat /sys/devices/system/cpu/cpu0/cpufreq/ondemand/sampling_rate`""
		echo -e "-\n"
	}
sgv()
	{
		# Set the scaling governor from the users choice:
		AVAILABLE_GOVERNORS="/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors"
		LIST=1
		for freq in `$BB cat $AVAILABLE_GOVERNORS`; do
			LIST=$(($LIST+1))
		done
		GOV_CHOICE=$1
		NEW_GOVERNOR=`$BB cat $AVAILABLE_GOVERNORS | $BB awk -v n="$GOV_CHOICE" '{print $n}'`
		if $BB test -z "$NEW_GOVERNOR"; then
			echo "${redf}Error:${cyanf} Invalid choice in $GOV_CHOICE"
			exit
		fi
		echo "$NEW_GOVERNOR" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
	}

sfrq()
	{

		# Set max/min frequency from users choice:
		AVAILABLE_FREQ="/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies"
		AVAILABLE_GOVERNORS="/sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors"
		FREQ_CHOICE=$2
		LIST=1
		for freq in `$BB cat $AVAILABLE_FREQ`; do
			LIST=$(($LIST+1))
		done	
		NEW_FREQ=`$BB cat $AVAILABLE_FREQ | $BB awk -v n="$FREQ_CHOICE" '{print $n}'`
		if $BB test $FREQ_CHOICE == $LIST; then
			exit
		elif $BB test -z "$NEW_FREQ"; then
			ECHO -l "${redf}Error:${cyanf} Invalid choice in $FREQ_CHOICE"
			exit
		else
			# Make sure min is not greater than max:
			if $BB test $1 == "min"; then
				if $BB test $NEW_FREQ -gt `$BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq`; then
					ECHO -l "${redf}Error:${cyanf} Can't set minimum speed higher than maximum speed"
					exit
				fi
			# Make sure max is not less than min:
			elif $BB test $1 == "max"; then
				if $BB test $NEW_FREQ -lt `$BB cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq`; then
					ECHO -l "${redf}Error:${cyanf} Can't set maximum speed lower than minimum speed"
					exit
				fi
			fi
		fi
		# Set the new frequency:
		echo "$NEW_FREQ" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_"$1"_freq
	}
###============
#- Main Script:
###============

checkBusybox
_sysrw > /dev/null

while $BB test "$1" == "no_color" -o "$1" == "-l" -o "$1" == "-nr"; do
	case "$1" in
		no_color)
			USE_COLORS=0
		;;
		-l)
			LOGGING=0
		;;
		-nr)
			PROMPT_REBOOT=0
		;;
	esac
	shift;
done

if $BB test $USE_COLORS -eq 1; then
	initializeColors
	echo -e ${cyanb} ${blackf}
fi

CMD=$($BB basename $0)
ARG=$@

if $BB test ! -z "${ARG}"  -a "$($BB basename $0)" == "${SCRIPT_NAME}"; then
	CMD=$1;	shift 1; ARG=$@
fi

case ${CMD} in
	ads)
		_ads ${ARG}
	;;
	allinone)
		_allinone ${ARG}
	;;
	apploc)
		_apploc ${ARG}
	;;
	backup)
		_backup ${ARG}
	;;
	bootani)
		_bootani ${ARG}
	;;
	cache)
		_cache ${ARG}
	;;
	camsound)
		_camsound ${ARG}
	;;
	clean)
		_clean ${ARG}
	;;
	compcache)
		_compcache ${ARG}
	;;
	chglog)
		_chglog ${ARG}
	;;
	donate)
		_donate ${ARG}
	;;
	exe)
		_exe ${ARG}
	;;
	fixperms)
		_fixperms ${ARG}
	;;
	freemem)
		_freemem ${ARG}
	;;
	install_zip)
		_install_zip ${ARG}
	;;
	lbo)
		mloadBootAnimation ${ARG}
	;;
	load)
		_load ${ARG}
	;;
	lfo)mloadFonts ${ARG};;
	lcl)
		mloadClock ${ARG}
	;;
	lkp)
		mloadKeypad ${ARG}
	;;
	lbl)
		mloadBootlogos ${ARG}
	;;
	lbs)
		mloadBootsound ${ARG}
	;;
	lwa)
		mloadAnim ${ARG}
	;;
	reapp)
		mremoveAnyApp ${ARG}
	;;
	ldn)
		mloadDns ${ARG}
	;;
	ss)
		rsetscaling ${ARG}
	;;
	sf)
		sfrq ${ARG}
	;;
	sg)
		sgv ${ARG}
	;;
	cpuinfo)
		cpuInfo ${ARG}
	;;
	market_history)
		_market_history ${ARG}
	;;
	pulldown_text)
		_pulldown_text ${ARG}
	;;
	rb)
		_rb ${ARG}
	;;
	restore)
		_restore ${ARG}
	;;
	rmapk)
		_rmapk ${ARG}
	;;
	setcpu)
		_setcpu ${ARG}
	;;
	setprops)
		_setprops ${ARG}
	;;
	setinits)
		_setinits ${ARG}
	;;	
	slim)
		_slim ${ARG}
	;;
	tvmh)
		mvmHeap ${ARG}
	;;
	sound)
		_sound ${ARG}
	;;
	switch)
		_switch ${ARG}
	;;
	symlink)
		_symlink ${ARG}
	;;
	sysro)
		_sysro ${ARG}
	;;
	sysrw)
		_sysrw ${ARG}
		echo -e ${reset}
		exit
	;;
	usb)
		_usb ${ARG}
	;;
	zipalign_apks)
		_zipalign_apks ${ARG}
	;;
	*)
		roottoolsUsage
	;;
esac

_sysro > /dev/null
echo -e ${reset}