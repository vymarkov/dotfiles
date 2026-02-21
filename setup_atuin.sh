#!/bin/sh

if [ ! -z $ATUIN_ENABLED ]; then
	echo "Atuin is enabled in the current workspace, let's configure it"
	if [ -z $ATUIN_KEY ]; then
		echo "Atuin key must be provided"
		exit 1
	fi
	atuin login -u $ATUIN_USERNAME -p $ATUIN_PASSWORD -k "$ATUIN_KEY"
	atuin sync
fi
