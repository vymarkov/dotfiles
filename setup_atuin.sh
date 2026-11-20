#!/bin/sh
# Non-interactive Atuin login for a workspace.
#
# `atuin login` reads these environment variables itself, so no secret is put
# on the command line (argv is visible in the process list):
#   ATUIN_PASSWORD        password (used when --password is not given)
#   ATUIN_ENCRYPTION_KEY  encryption key (used when --key is not given)
# The username has no environment variable, so it is passed with -u.
# Any other setting can be overridden the same way, e.g. ATUIN_SYNC_ADDRESS
# (prefix ATUIN_, nested keys separated by "__").
#
# Inputs: ATUIN_ENABLED (gate), ATUIN_USERNAME, ATUIN_PASSWORD, and
# ATUIN_ENCRYPTION_KEY (legacy name ATUIN_KEY is still accepted).

if [ -n "$ATUIN_ENABLED" ]; then
	echo "Atuin is enabled in the current workspace, let's configure it"

	# Legacy name used by older workspace environments.
	ATUIN_ENCRYPTION_KEY="${ATUIN_ENCRYPTION_KEY:-$ATUIN_KEY}"

	if [ -z "$ATUIN_USERNAME" ]; then
		echo "Atuin username must be provided (ATUIN_USERNAME)"
		exit 1
	fi
	if [ -z "$ATUIN_PASSWORD" ]; then
		echo "Atuin password must be provided (ATUIN_PASSWORD)"
		exit 1
	fi
	if [ -z "$ATUIN_ENCRYPTION_KEY" ]; then
		echo "Atuin key must be provided (ATUIN_ENCRYPTION_KEY)"
		exit 1
	fi

	export ATUIN_PASSWORD ATUIN_ENCRYPTION_KEY
	atuin login -u "$ATUIN_USERNAME" || exit 1
	atuin sync
fi
