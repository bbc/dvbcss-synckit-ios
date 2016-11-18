#!/bin/sh

COMMON="jazzy.common.yaml"

# must have trailing slash...
REPO_BROWSE_ROOT="https://github.com/bbc/dvbcss-synckit-ios/tree/master/"
DOCS_ROOT="http://bbc.github.io/dvbcss-synckit-ios/latest/"



# 1) Process READMEs to create version with following changes:
#    a) multi-line sections removed that are delimited by
#          [](---START EXCLUDE FROM DOC BUILD---)
#             ...
#          [](---END EXCLUDE FROM DOC BUILD---)
#
#    b) rewrite relative URLs that are not purely fragment URLs to point to github
#       (basically URLs not beginning with a scheme such as 'http:' or with '#')
#
#    c) rewrite URLs of the form:
#          http://bbc.github.io/dvbcss-synckit-ios/latest/XXXX
#       as relative URLs of the form:
#          ../XXXX
(
	cd ..

	for README_FILE in `find . -name README.md`; do
		MODIFIED_README_FILE="${README_FILE/README.md/doc-build-README.md}"
		
		PATH_IN_REPO=`dirname "$README_FILE" | sed -e 's/^.\///'`

		echo "Preprocessing $README_FILE"
		echo "... writing out as $MODIFIED_README_FILE"
		echo "... $PATH_IN_REPO"

		cat "$README_FILE" | perl -0777 -pe '\
			s"\Q[](---START EXCLUDE FROM DOC BUILD---)\E.*?\Q[](---END EXCLUDE FROM DOC BUILD---)\E\s*\n?""gs; \
			s"(\[[^]]+\]\()(?![a-zA-Z][-.+0-9a-zA-Z]*:)([^#)][^)]*\))"\1'${REPO_BROWSE_ROOT}${PATH_IN_REPO}'/\2"gs; \
			s"\Q'$DOCS_ROOT'\E"../"gs; ' > "$MODIFIED_README_FILE"
	done

	for CONFIG_TEMPLATE in `find . -name jazzy.template.yaml`; do
		echo "Processing jazzy template: $CONFIG_TEMPLATE";
		
		SUBDIR=`dirname "$CONFIG_TEMPLATE"`
		cat "$CONFIG_TEMPLATE" "docs/$COMMON" > "$SUBDIR/jazzy.merged.yaml"
		(
			cd $SUBDIR;
			jazzy --config jazzy.merged.yaml;
		)
	done

)