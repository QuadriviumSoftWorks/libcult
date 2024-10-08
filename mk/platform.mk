.DEFAULT_GOAL:=all

ifeq ($(OS),Windows_NT)
	HOST=winnt
	ifeq ($(PROCESSOR_ARCHITEW6432),AMD64)
		PROC=amd64
	else # ifeq $(PROCESSOR_ARCHITEW6432),AMD64)
		ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
			PROC=amd64
		endif # ifeq ($(PROCESSOR_ARCHITECTURE),AMD64)
		ifeq ($(PROCESSOR_ARCHITECTURE),x86)
			PROC=x86
		endif # ifeq ($(PROCESSOR_ARCHITECTURE),x86)
	endif # ifeq ($(PROCESSOR_ARCHITEW6432,AMD64)
else # ifneq ($(OS),Windows_NT)
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		HOST=linux
	endif # ifeq ($(UNAME_S),Linux)
	ifeq ($(UNAME_S),Darwin)
		HOST=macos
	endif # ifeq ($(UNAME_S),Darwin)

	UNAME_P := $(shell uname -p)
	ifeq ($(UNAME_P),x86_64)
		PROC=amd64
	endif # ifneq ($(UNAME_P),x86_64)
	ifneq ($(filter %86,$(UNAME_P)),)
		PROC=x86
	endif # ($(filter %86,$(UNAME_P)),)
	ifneq ($(filter arm%,$(UNAME_P)),)
		PROC=arm
	endif # ifneq ($(filter arm%,$(UNAME_P)),)
endif # ifeq ($(OS),Windows_NT)

ARCH?=$(HOST)

B:=build/$(ARCH)/$(PROC)/bin
L:=build/$(ARCH)/$(PROC)/lib
D:=build/$(ARCH)/$(PROC)/dep
O:=build/$(ARCH)/$(PROC)/obj
T:=build/$(ARCH)/$(PROC)/tst

build:
	mkdir -p $@
build/$(ARCH): build
	mkdir -p $@
build/$(ARCH)/$(PROC): build/$(ARCH)
	mkdir -p $@
$(O): build/$(ARCH)/$(PROC)
	mkdir -p $@
$(D): build/$(ARCH)/$(PROC)
	mkdir -p $@
$(L): build/$(ARCH)/$(PROC)
	mkdir -p $@
$(B): build/$(ARCH)/$(PROC)
	mkdir -p $@
$(T): build/$(ARCH)/$(PROC)
	mkdir -p $@
