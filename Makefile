#~ Docker Project

.PHONY: default docker publish
default: package

package:                 # Build the docker image
	@./Make.sh package

publish:                # Publish the docker image
	@./Make.sh publish
