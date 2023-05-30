ROOT=$(realpath $(dir $(lastword $(MAKEFILE_LIST))))

all: config.sh stage1 stage2 stage3
	@bash build.sh

menuconfig:
	~/.local/bin/menuconfig $(ROOT)/Kconfig

clean:
	@rm -rf build src tools sysroot
	@rm -rf .config .config.old config.sh
	@rm -rf stage1 stage2 stage3

stage1:
	@mkdir -p $(ROOT)/stage1
	@ln -sf ../packages/{linux-headers,binutils,gcc,glibc,gcc-libstdcxx} $(ROOT)/stage1/

stage2:
	@mkdir -p $(ROOT)/stage2

stage3:
	@mkdir -p $(ROOT)/stage3

config.sh: .config
	@rm -rf $@
	@ARCH=$$(grep "^CONFIG_ARCH_.*=y" $< | sed "s/^CONFIG_ARCH_\(.*\)=y/\1/" | tr '[:upper:]' '[:lower:]'); \
	echo "ARCH=$$ARCH-linux-gnu" >> config.sh;

.config:
	$(error Please run menuconfig first)

.PHONY: all menuconfig clean