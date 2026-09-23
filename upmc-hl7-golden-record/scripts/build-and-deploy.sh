#!/usr/bin/env bash
# =============================================================================
# build-and-deploy.sh
#
# Packages the HL7GoldenRecordFlow project into a BAR file and deploys it
# to the local ace-server Podman container via the ACE REST Admin API.
#
# Prerequisites:
#   - ace-server Podman container is running  (podman start ace-server)
#   - ACE toolkit mqsipackagebar is available in PATH, OR
#     the script uses the REST API deploy path if mqsipackagebar is absent
#
# Usage:
#   ./scripts/build-and-deploy.sh
# =============================================================================
set -euo pipefail

ACE_ADMIN_URL="http://localhost:7600"
BAR_FILE="bar-build/upmc-hl7-golden-record.bar"
PROJECT_DIR="upmc-hl7-golden-record"
SERVER_NAME="default"

echo "==> Checking ace-server container is running..."
if ! podman ps --format "{{.Names}}" | grep -q "ace-server"; then
    echo "ERROR: ace-server container is not running."
    echo "       Run: podman start ace-server"
    exit 1
fi

echo "==> Packaging BAR file..."
if command -v mqsipackagebar &>/dev/null; then
    mqsipackagebar \
        -w . \
        -a "${BAR_FILE}" \
        -k "${PROJECT_DIR}"
    echo "    BAR packaged via mqsipackagebar: ${BAR_FILE}"
else
    echo "    mqsipackagebar not found — using ACE REST Admin API file deploy..."
fi

echo "==> Deploying to ace-server (${ACE_ADMIN_URL})..."
HTTP_STATUS=$(curl -s -o /tmp/ace-deploy-response.json -w "%{http_code}" \
    -X POST \
    "${ACE_ADMIN_URL}/apiv2/servers/${SERVER_NAME}/deploy" \
    -H "Content-Type: application/json" \
    -d "{\"type\":\"bar\",\"path\":\"/${BAR_FILE}\"}")

if [ "${HTTP_STATUS}" = "200" ] || [ "${HTTP_STATUS}" = "202" ]; then
    echo "==> Deploy successful (HTTP ${HTTP_STATUS})"
    cat /tmp/ace-deploy-response.json | python3 -m json.tool 2>/dev/null || true
else
    echo "ERROR: Deploy returned HTTP ${HTTP_STATUS}"
    cat /tmp/ace-deploy-response.json
    exit 1
fi

echo ""
echo "==> Flow is live. Test it:"
echo "    curl -s -X POST http://localhost:7800/hl7/golden-record \\"
echo "         -H 'Content-Type: x-application/hl7-v2+er7' \\"
echo "         --data-binary @upmc-hl7-golden-record/testdata/adt-a01-valid.hl7 | python3 -m json.tool"
