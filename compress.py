# hi guys
import ctypes
import os

SO_PATH = os.path.join(os.path.dirname(__file__), "libcompress.so")
lib = ctypes.CDLL(SO_PATH)

lib.asm_compress.restype = ctypes.c_size_t
lib.asm_compress.argtypes = [
    ctypes.POINTER(ctypes.c_uint8),
    ctypes.c_char_p,
    ctypes.c_size_t,
]

lib.asm_decompress.restype = ctypes.c_size_t
lib.asm_decompress.argtypes = [
    ctypes.c_char_p,
    ctypes.POINTER(ctypes.c_uint8),
    ctypes.c_size_t,
    ctypes.c_size_t,
]


def compress(text: str) -> bytes: #compress
    raw = text.encode("utf-8")
    buf = (ctypes.c_uint8 * (len(raw) + 16))()
    out_len = lib.asm_compress(buf, raw, len(raw))
    return bytes(buf[:out_len])


def decompress(data: bytes, orig_len: int) -> str: # decompress
    in_buf = (ctypes.c_uint8 * len(data)).from_buffer_copy(data)
    out_buf = ctypes.create_string_buffer(orig_len + 16)
    lib.asm_decompress(out_buf, in_buf, len(data), orig_len)
    return out_buf.value.decode("utf-8")


if __name__ == "__main__": # data can be inserted here
    text = "hello world hello world hello!"
    compressed = compress(text)
    decompressed = decompress(compressed, len(text))

    print(f"Original Text    ({len(text)} bytes): '{text}'")
    print(f"Compressed Output ({len(compressed)} bytes): {compressed.hex()}")
    print(f"Decompressed Text ({len(decompressed)} bytes): '{decompressed}'")
    print(f"Space Saved      : {((1 - len(compressed)/len(text))*100):.1f}%")
