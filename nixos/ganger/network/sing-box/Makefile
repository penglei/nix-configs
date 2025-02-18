.PHONY: build rsync

build:
	@./hack/build.sh

render: build
	@./hack/render.sh


rsync: render
	@rsync -avh ./outputs/* scripts ganger:~/sing-box/ \
	--exclude .direnv --include='**.gitignore' --filter=':- .gitignore' --delete-after

