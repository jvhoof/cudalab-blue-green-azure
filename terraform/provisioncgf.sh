#!/bin/bash
{
echo "Starting Cloud Init..."
echo "Barracuda Firewall Control Center bootstrap. Fetching PAR from $CCIP RangeID: $CCRANGEID ClusterName: $CCCLUSTERNAME Firewall Name: $CGFNAME"
echo "*/2 * * * * root echo \"$CCSECRET\" | /opt/phion/bin/getpar -a $CCIP -r $CCRANGEID -c $CCCLUSTERNAME -b $CGFNAME -d /opt/phion/update/box.par -s --verbosity 10 >> /tmp/getpar.log && /etc/rc.d/init.d/phion stop && /etc/rc.d/init.d/phion start && rm /etc/cron.d/getpar" > /etc/cron.d/getpar
} >> /tmp/provision.log 2>&1