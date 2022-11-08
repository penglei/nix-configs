.PHONY: build rsync

build:
	@./hack/build.sh

#render a ad-hoc config in local for debugging or developing
render: build
	@./hack/render.sh

#sync rendered output to a server
SERVER ?= ganger
rsync: render
	@rsync -avh ./outputs/* hack $(SERVER):~/sing-box/ \
	--exclude .direnv --include='**.gitignore' --filter=':- .gitignore' --delete-after
