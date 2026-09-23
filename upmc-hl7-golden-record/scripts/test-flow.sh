#!/usr/bin/env bash
# =============================================================================
# test-flow.sh
#
# Sends test HL7 messages to the running HL7GoldenRecordFlow and displays
# the responses.  Demonstrates the two key scenarios for the demo:
#
#   Test 1 — Valid ADT^A01 (MRN000001 / Julianne Bashirian)
#             Expected: HTTP 200 + JSON Golden Record Candidate
#
#   Test 2 — Missing MRN (same patient, PID-3 deliberately blank)
#             Expected: HTTP 422 + structured error payload
#
# Usage:
#   ./scripts/test-flow.sh
# =============================================================================
set -euo pipefail

FLOW_URL="http://localhost:7800/hl7/golden-record"
TESTDATA_DIR="upmc-hl7-golden-record/testdata"

echo "========================================================"
echo " UPMC HL7 → Golden Record Flow — Demo Test Runner"
echo "========================================================"
echo ""

# ------------------------------------------------------------------
# Test 1: Valid ADT^A01
# ------------------------------------------------------------------
echo "--- Test 1: Valid ADT^A01 (MRN000001 — Julianne Bashirian) ---"
echo ""

HTTP_STATUS=$(curl -s -o /tmp/test1-response.json -w "%{http_code}" \
    -X POST "${FLOW_URL}" \
    -H "Content-Type: x-application/hl7-v2+er7" \
    --data-binary @"${TESTDATA_DIR}/adt-a01-valid.hl7")

echo "HTTP Status: ${HTTP_STATUS}"
echo "Response:"
python3 -m json.tool /tmp/test1-response.json 2>/dev/null || cat /tmp/test1-response.json
echo ""

if [ "${HTTP_STATUS}" = "200" ]; then
    echo "✅ Test 1 PASSED — Golden Record Candidate returned"
else
    echo "❌ Test 1 FAILED — Expected 200, got ${HTTP_STATUS}"
fi

echo ""
echo "--------------------------------------------------------"
echo ""

# ------------------------------------------------------------------
# Test 2: Missing MRN (error case)
# ------------------------------------------------------------------
echo "--- Test 2: Missing MRN (error path — MDM dead-letter scenario) ---"
echo ""

HTTP_STATUS=$(curl -s -o /tmp/test2-response.json -w "%{http_code}" \
    -X POST "${FLOW_URL}" \
    -H "Content-Type: x-application/hl7-v2+er7" \
    --data-binary @"${TESTDATA_DIR}/adt-a01-missing-mrn.hl7")

echo "HTTP Status: ${HTTP_STATUS}"
echo "Response:"
python3 -m json.tool /tmp/test2-response.json 2>/dev/null || cat /tmp/test2-response.json
echo ""

if [ "${HTTP_STATUS}" = "422" ]; then
    echo "✅ Test 2 PASSED — Validation error correctly returned"
else
    echo "❌ Test 2 FAILED — Expected 422, got ${HTTP_STATUS}"
fi

echo ""
echo "========================================================"
echo " Done."
echo "========================================================"
