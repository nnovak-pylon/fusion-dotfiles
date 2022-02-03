all: sync

sync: build
	./dotfiles

delete: build
	./dotfiles --delete

build:
	go build
