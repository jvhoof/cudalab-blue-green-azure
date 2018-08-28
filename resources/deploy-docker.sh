#!/bin/bash
echo "
##############################################################################################################
#  _                         
# |_) _  __ __ _  _     _| _ 
# |_)(_| |  | (_|(_ |_|(_|(_|
#
# Local deployment bootstrap
#
##############################################################################################################
"

while getopts "bg" option; do
    case "${option}" in
        b) DEPLOYMENTCOLOR="blue" ;;
        g) DEPLOYMENTCOLOR="green" ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

DEPLOYMENTVARFILE="var-$DEPLOYMENTCOLOR.env"

# Terraform state file in Azure Storage
BACKEND_ARM_ACCESS_KEY=''

# Passwords
CCSECRET=''
DB_PASSWORD=''
PASSWORD=''
SSH_KEY_DATA=''

# Azure Credentials
AZURE_CLIENT_ID=''
AZURE_CLIENT_SECRET=''
AZURE_SUBSCRIPTION_ID=''
AZURE_TENANT_ID=''

echo ""
echo "==> Starting local Docker container for $DEPLOYMENTCOLOR deployment"
echo ""

docker run --rm -itv $PWD/../vsts-cudalab-blue-green:/data \
                    -v terraform-run:/.terraform/ \
                    -v ~/.ssh:/ssh/ \
                    --env-file $DEPLOYMENTVARFILE \
                    jvhoof/cloudgen-essentials \
                    /bin/bash -c "cd /data; ./deploy.sh -a '-v' -b '$BACKEND_ARM_ACCESS_KEY' -c '$CCSECRET' -d '$DB_PASSWORD' -p '$PASSWORD' -s '$SSH_KEY_DATA' -v '$AZURE_CLIENT_ID' -w '$AZURE_CLIENT_SECRET' -x '$AZURE_SUBSCRIPTION_ID' -y '$AZURE_TENANT_ID' -z '$DEPLOYMENTCOLOR'"
