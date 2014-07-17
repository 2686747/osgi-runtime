#!/bin/bash
#v.1.201407171141
#OSGI runtime
#load Felix Framework Distribution + org.apache.felix.shell-x.x.x.jar, 
#org.apache.felix.shell.remote-x.x.x.jar, 
#install this bundles into current folder,
#copy settings from CONF_SRC to CONF_DEST({framework folder}/conf)
# start framework
#exit 1 - if error


#log data
LOG=logs/setup.log
DATE_FORMAT="%F.%T.%N"

#framework version
VERSION=4.4.1
FRAMEWORK="org.apache.felix.main.distribution-$VERSION"

#settings file
CONF_SRC=config/config.properties

#write to log file in format date:message
log(){
	echo `date +"$DATE_FORMAT"`" :$1" >> $LOG
}

#download from $1 (parameter for wget), log, exit 1 if failure
download(){
	log "downloading:$1"
	if ( ! wget $1)
	then
		log "error downloading:$1"
		exit 1
	else
		log "success downloading"
	fi
}

#write to file $1 "$2=$3" 
#using:writeToFile file value_name value as value_name=value
writeToFile(){
	#echo $1:$2 > $DF
	#echo $2 $3 'in' $1
	if [ ! -w $1 ]
	then
		touch $1
	fi 
	if [ "$2" != "" ] 
	then
		RES=`sed -i "s/$2.*$/$2=$3/" $1`
		#RES=`grep -P $2 $1`
		#echo $RES
		if ! RES=`grep -P $2 $1`
		then
			echo -en "\\n$2:$3" >> $1
		fi
	fi

}



#get framework
URL="http://www.eu.apache.org/dist//felix/$FRAMEWORK.tar.gz"

download "-O ./$FRAMEWORK.tar.gz $URL"

#define current framework folder
log "define current framework folder..."
#FRAMEWORK_FOLDER=`tar -tf $FRAMEWORK.tar.gz | grep -m 1 -o .*$VERSION/`
FRAMEWORK_FOLDER=lib/
log "defined folder:$FRAMEWORK_FOLDER"
log "unarchiving framework..."
tar -xf   ./$FRAMEWORK.tar.gz -C $FRAMEWORK_FOLDER --strip-components=1
		
rm $FRAMEWORK.tar.gz

#get additional plugins
FILE="org.apache.felix.shell.remote-1.1.2.jar"
URL="http://www.eu.apache.org/dist//felix/$FILE"
download "-O "$FRAMEWORK_FOLDER"bundle/$FILE $URL"



FILE="org.apache.felix.shell-1.4.3.jar"
URL="http://www.eu.apache.org/dist//felix/$FILE"
download "-O "$FRAMEWORK_FOLDER"bundle/$FILE $URL"
#java -Dfelix.config.properties=file:./config/config.properties -jar $BUNDLE/bin/felix.jar

#add config from config/config.properties
CONF_DEST="$FRAMEWORK_FOLDER"conf/config.properties
log "add settings from $CONF_SRC to $CONF_DEST"
cat $CONF_SRC >> $CONF_DEST

log "change ip($OPENSHIFT_OSGI_IP) for telnet"
#  $OPENSHIFT_OSGI_IP - cartridge ip
#add cartridge ip
if [ $OPENSHIFT_OSGI_IP ] 
then
	writeToFile  $CONF_DEST "osgi.shell.telnet.ip" "$OPENSHIFT_OSGI_IP"
	log "success: ip:$OPENSHIFT_OSGI_IP"
else
	log "failure: ip not changed"
fi

#start framework
cd $FRAMEWORK_FOLDER
JAVA_ARG="bin/felix.jar"
log "starting framework:$JAVA_ARG"
#java -jar $JAVA_ARG &

exit 0
