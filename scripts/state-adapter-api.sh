#!/usr/bin/env bash
# Zenflow State Store — API adapter (DynamoDB + S3)
# Sourced by zenflow-store-state.sh. Never invoke directly.
#
# NOT YET IMPLEMENTED.
# Set ZENFLOW_STATE_ADAPTER=api when the DynamoDB+S3 service is ready.
# This adapter will support cross-machine resume and team handoff.

echo "Zenflow error: API adapter not yet implemented. Use ZENFLOW_STATE_ADAPTER=local (the default)." >&2
return 1
