#!/bin/sh

COMMON="jazzy.common.yaml"

for CONFIG_TEMPLATE in `find .. -name jazzy.template.yaml`; do
	SUBDIR=`dirname "$CONFIG_TEMPLATE"`
	cat "$CONFIG_TEMPLATE" "$COMMON" > "$SUBDIR/jazzy.merged.yaml"
	(
		cd $SUBDIR;
		jazzy --config jazzy.merged.yaml;
	)
done
