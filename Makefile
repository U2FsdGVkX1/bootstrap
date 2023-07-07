ROOT=$(realpath $(dir $(lastword $(MAKEFILE_LIST))))

all: stage2

menuconfig:
	~/.local/bin/menuconfig $(ROOT)/Kconfig

clean:
	@rm -rf build tools sysroot
	@rm -rf .config .config.old config.sh
	@rm -rf stage1 stage2 stage3

stage1: config.sh
	@mkdir -p $(ROOT)/stage1
	@ln -sf ../packages/toolchains/{linux-headers,binutils,gcc-lite,glibc,gcc} $(ROOT)/stage1/
	@bash -e build.sh "" 1

stage2: stage1 config.sh
	@mkdir -p $(ROOT)/stage2
	@ln -sf ../packages/base/{rootfs,m4,coreutils,diffutils,findutils} $(ROOT)/stage2/
	@ln -sf ../packages/base/{gawk,grep,gzip,xz,tar,patch,sed,file,bash,make,iproute2,eudev,wget-lite} $(ROOT)/stage2/
	@ln -sf ../packages/toolchains/{linux-headers,binutils,glibc,gcc} $(ROOT)/stage2/
	@bash -e build.sh "" 2
	@mkdir -p sysroot/bootstrap
	@cp -r $(ROOT)/{packages,scripts,.config,build.sh,Makefile} sysroot/bootstrap

stage3: config.sh
	@mkdir -p $(ROOT)/stage3
	@ln -sf ../packages/rpms/{locale,zlib,perl,openssl,wget,pkg-config,curl} $(ROOT)/stage3/
	@ln -sf ../packages/rpms/{util-linux,gettext,git,bzip2,zstd} $(ROOT)/stage3/
	# @ln -sf ../packages/rpms/{libgpg-error,libgcrypt,libassuan,libksba,npth,gnupg} $(ROOT)/stage3/
	@ln -sf ../packages/rpms/{libgpg-error,libgcrypt} $(ROOT)/stage3/
	@ln -sf ../packages/rpms/{libffi,popt,libarchive,sqlite,lua,python,rpm} $(ROOT)/stage3/
	@ln -sf ../packages/rpms/{help2man,rpmdevtools} $(ROOT)/stage3/
	@bash -e build.sh "" 3

config.sh: .config
	@rm -rf $@
	@ARCH=$$(grep "^CONFIG_ARCH_.*=y" $< | sed "s/^CONFIG_ARCH_\(.*\)=y/\1/" | tr '[:upper:]' '[:lower:]'); \
	echo "ARCH=$$ARCH-unknown-linux-gnu" >> config.sh;

.config:
	$(error Please run menuconfig first)

.PHONY: all menuconfig clean
