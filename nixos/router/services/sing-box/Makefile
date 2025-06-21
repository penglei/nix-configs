.PHONY: build rsync

build:
	@./hack/build.sh

#render a ad-hoc config in local for debugging or developing
render: build
	@./hack/render.sh

#sync rendered output to a server
#
#[root@router:~]# systemctl stop pppoe-sing-box-trigger.path
#[root@router:~]# systemctl stop sing-box
#❯ cd ~/sing-box
#❯ ./hack/run.sh
SERVER ?= router
rsync: render
	@rsync -avh ./outputs/* hack $(SERVER):~/sing-box/ \
	--exclude .direnv --include='**.gitignore' --filter=':- .gitignore' --delete-after
