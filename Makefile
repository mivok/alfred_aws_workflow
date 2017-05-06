FILES=icon.png info.plist query.jq script_filter.sh

AWS.alfredworkflow: $(FILES)
	zip $@ $(FILES)

clean:
	rm -f AWS.alfredworkflow
