# the double make is for OSX' sake
# I don't know why, but it doesn't work the first time
all:
	@mkdir -p build
	@cd build; cmake ..
	@make -C build 2>/dev/null || make -C build

clean:
	@rm -rf build

install: all
	@make install -C build

.PHONY: all install
