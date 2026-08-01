CC = gcc
CFLAGS = -shared -fPIC -O3
TARGET = libcompress.so
SRCS = compress.s

all: $(TARGET)

$(TARGET): $(SRCS)
	$(CC) $(CFLAGS) -o $(TARGET) $(SRCS)

clean:
	rm -f $(TARGET) *.o
