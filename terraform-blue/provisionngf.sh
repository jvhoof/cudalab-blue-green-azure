#!/bin/bash
{
echo "Starting Cloud Init..."
echo "NG Control Center bootstrap. Fetching PAR from $NGCCIP RangeID: $NGCCRANGEID ClusterName: $NGCCCLUSTERNAME Firewall Name: $NGFNAME"
echo "*/2 * * * * root echo \"$NGCCSECRET\" | /opt/phion/bin/getpar -a $NGCCIP -r $NGCCRANGEID -c $NGCCCLUSTERNAME -b $NGFNAME -d /opt/phion/update/box.par -s --verbosity 10 >> /tmp/getpar.log && /etc/rc.d/init.d/phion stop && /etc/rc.d/init.d/phion start && rm /etc/cron.d/getpar" > /etc/cron.d/getpar
} >> /tmp/provision.log 2>&1