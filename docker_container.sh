#!/bin/bash
OVBIN=/opt/OV/bin
group="YAZ"
application=“YAZ”
company="F"
category="YAZ"
object="Container"
IPADDRESS=$(ifconfig -a eth1 | awk 'NR ==2 {print $2}')
HOSTNAME=$(hostname)

mapfile -t containerslist < <( docker ps --format "{{ .Names  }}" )



while :
do

	for CONTAINER in "${containerslist[@]}"
	do
	    RUNNINGSTATE=$(docker inspect --format="{{ .State.Running }}" $CONTAINER)
	    PID=$(docker inspect --format="{{ .State.Pid }}" $CONTAINER)
	    CONTAINER_ID=$(docker inspect --format="{{ .Config.Hostname }}" $CONTAINER)
	    LOGDATE=$(date +%d%m%Y)


		if [[ "$RUNNINGSTATE" == "false" ]]; then
		    while :
		    do

		    	RUNNINGSTATE_NEW=$(docker inspect --format="{{ .State.Running }}" $CONTAINER)
		    	ALERTDATE=$(date +%d-%m-%Y-%T)

		     	if [[ "$RUNNINGSTATE_NEW" == "false" ]]; then
		      		
		      		echo "$ALERTDATE - NOK - Alert on $HOSTNAME ($IPADDRESS) for $CONTAINER is TRIGGERED" >> /app/containermonitor/log/"$LOGDATE"_containermon.log

			        $OVBIN/opcmon TT_Opcmon_Policy=1 -object "$object" -option application="$application" -option msg_grp="$category" -option company="$company" -option group="$group" -option object="$object" -option msg_text="$IPADDRESS $CONTAINER is down on $HOSTNAME"

			        echo "
			        Date: $ALERTDATE
			        Container: $CONTAINER
			        Status: $RUNNINGSTATE_NEW
			        IP: $IPADDRESS
			        Hostname: $HOSTNAME

			        $CONTAINER is DOWN on $HOSTNAME - $IPADDRESS" | mailx -v -s "$CONTAINER is DOWN on $HOSTNAME" -r "yaz@turktelekom.com.tr" -S smtp="10.234.204.10:587" unsal.erkal@partner.turktelekom.com.tr,emre.ozdemir2@partner.turktelekom.com.tr,tugrul.tuncer@partner.turktelekom.com.tr,oguzhan.ince@partner.turktelekom.com.tr,karabacak.mehmetbalkan@turktelekom.com.tr,cemre.mengu@ttgint.com,murat.bicakci@ttgint.com,halil.kural@ttgint.com,dogukan.tasdemir@ttgint.com,furkan.uyanik@ttgint.com 2> /dev/null

			    else

			    	echo "$ALERTDATE - FINE - Alert on $HOSTNAME ($IPADDRESS) for $CONTAINER is CLEARED" >> /app/containermonitor/log/"$LOGDATE"_containermon.log

			        $OVBIN/opcmon TT_Opcmon_Policy=10 -object "$object" -option application="$application" -option msg_grp="$category" -option company="$company" -option group="$group" -option object="$object" -option msg_text="$IPADDRESS $CONTAINER is up on $HOSTNAME"

			        echo "
			        Date: $ALERTDATE
			        Container: $CONTAINER
			        Status: $RUNNINGSTATE_NEW
			        IP: $IPADDRESS
			        Hostname: $HOSTNAME

			        $CONTAINER is UP on $HOSTNAME - $IPADDRESS" | mailx -v -s "$CONTAINER is UP on $HOSTNAME" -r "yaz@turktelekom.com.tr" -S smtp="10.234.204.10:587" unsal.erkal@partner.turktelekom.com.tr,emre.ozdemir2@partner.turktelekom.com.tr,tugrul.tuncer@partner.turktelekom.com.tr,oguzhan.ince@partner.turktelekom.com.tr,karabacak.mehmetbalkan@turktelekom.com.tr,cemre.mengu@ttgint.com,murat.bicakci@ttgint.com,halil.kural@ttgint.com,dogukan.tasdemir@ttgint.com,furkan.uyanik@ttgint.com 2> /dev/null

			        break 
		       	fi
		       	sleep 10m
		    done

		        #continue 
		else

			OKDATE=$(date +%d-%m-%Y-%T)
		    echo "$OKDATE - OK - $HOSTNAME ($IPADDRESS) for $CONTAINER is OK" >> /app/containermonitor/log/"$LOGDATE"_containermon.log
		fi
	done
	sleep 10m
done