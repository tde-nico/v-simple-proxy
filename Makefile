all:
	v -skip-unused -prod -compress -gc none -cflags "-static" main.v

run:
	@ v run main.v

.PHONY: all