#!/bin/bash

SUBSCRIPTION_ID="${1:-}"

echo "=== Azure Subscription Check ==="

echo "[1/3] Checking login status..."
az account show &> /dev/null
if [ $? -ne 0 ]; then
    echo "ERROR: Not logged in. Run: az login"
    exit 1
fi
echo "      ✓ Logged in"

echo "[2/3] Fetching subscription..."
if [ -n "$SUBSCRIPTION_ID" ]; then
    SHOW_CMD="az account show --subscription $SUBSCRIPTION_ID"
else
    SHOW_CMD="az account show"
fi

# Pull fields directly via --query (no Python needed)
NAME=$(  $SHOW_CMD --query "name"     --output tsv 2>&1)
SUB_ID=$($SHOW_CMD --query "id"       --output tsv 2>&1)
TENANT=$($SHOW_CMD --query "tenantId" --output tsv 2>&1)
STATE=$( $SHOW_CMD --query "state"    --output tsv 2>&1)

if [ $? -ne 0 ] || [ -z "$STATE" ]; then
    echo "ERROR: Subscription not found or inaccessible."
    echo "       $STATE"
    exit 1
fi

echo "[3/3] Subscription details:"
echo "      Name        : $NAME"
echo "      ID          : $SUB_ID"
echo "      Tenant ID   : $TENANT"
echo "      State       : $STATE"

if [ "${STATE,,}" == "enabled" ]; then
    echo "      Status      : ✓ ACTIVE"
else
    echo "      Status      : ✗ NOT ACTIVE ($STATE)"
    exit 1
fi