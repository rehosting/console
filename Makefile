BUILD?=build
CFLAGS=-O2 -Wall
LDFLAGS=-static
ARCH ?= x86_64-linux-gnu

CFLAGS += -DSHELL=\"/igloo/utils/sh\"
CFLAGS += -DSERIAL=\"/igloo/serial\"


SOURCES=console.c
OBJECTS=$(SOURCES:.c=.o)
TARGET=$(BUILD)/console-${ARCH}

ifeq ($(ARCH),mipsel-linux-musl)
CFLAGS += -mips32r3
else ifeq ($(ARCH),mipseb-linux-musl)
CFLAGS += -mips32r3
else ifeq ($(ARCH),mips64eb-linux-musl)
CFLAGS += -mips64r2
else ifeq ($(ARCH),mips64el-linux-musl)
CFLAGS += -mips64r2
endif

all: $(SOURCES) $(TARGET)

$(TARGET): $(SOURCES)
	$(CC) $(LDFLAGS) $(CFLAGS) $< -o $@

clean:
	rm -f $(BUILD)/console*

.PHONY: clean
