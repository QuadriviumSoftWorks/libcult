-include mk/platform.mk
ifeq ($(ARCH),linux)
-include mk/linux.mk
else
-include mk/winnt.mk
endif # ifeq ($(HOST),linux)

PROJ?=libcult

ifeq ($(HOST),linux)
	ifeq ($(ARCH),winnt)
		CC=x86_64-w64-mingw32-gcc
		AS=x86_64-w64-mingw32-as
		AR=x86_64-w64-mingw32-ar
		ENV=wine
	endif # ifeq ($(ARCH),winnt)
endif # ifeq ($(HOST),linux)

CPPFLAGS?=
CFLAGS?=
LDFLAGS?=

ALL_CFLAGS:=-fPIC -ffreestanding $(CFLAGS)
ALL_CPPFLAGS:=-Iinclude $(CPPFLAGS)
ALL_LDFLAGS:=-L$(L) $(LDFLAGS)

ifeq ($(HOST),linux)
PREFIX?=/usr/local
endif # ifeq ($(HOST),linux)

ifeq ($(HOST),winnt)
PREFIX?=C:/
endif # ifeq ($(HOST),winnt)

.PHONY:all arch clean install libcult
all: libcult

libcult: $(LIBCULT_LIB)

arch:
	@echo "Host OS: $(HOST)"
	@echo "Building for: $(ARCH)-$(PROC)"

tests: $(LIBCULT_TST)
	@for TST in $(LIBCULT_TST); do \
		$(ENV) $$TST; \
	done

install: $(LIBCULT_LIB)
	install -m 0644 $(L)/libcult.a $(PREFIX)/lib/libcult.a
	mkdir -p $(PREFIX)/include/libcult
	install -m 0644 include/libcult/libcult.h $(PREFIX)/include/libcult/libcult.h
	mkdir -p $(PREFIX)/include/libcult/arch/$(ARCH)/$(PROC)
	install -m 0644 include/libcult/arch/$(ARCH)/$(PROC)/api.h $(PREFIX)/include/libcult/arch/$(ARCH)/$(PROC)/api.h
	install -m 0644 include/libcult/arch/$(ARCH)/$(PROC)/ops.h $(PREFIX)/include/libcult/arch/$(ARCH)/$(PROC)/ops.h

clean:
	rm -rf build/$(ARCH)/$(PROC)/

-include $(D)/*
