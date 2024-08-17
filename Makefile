.PHONY: all clean install

PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
SWIFTC ?= swiftc
INSTALL ?= install

all: trash

trash: trash.swift
	$(SWIFTC) -v -O -o $@ $<

install: trash
	$(INSTALL) -v -C -m 755 $< $(BINDIR)/$<

uninstall:
	rm -f $(BINDIR)/trash

clean:
	rm -f trash
