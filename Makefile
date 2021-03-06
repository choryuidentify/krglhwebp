
CC = i686-w64-mingw32-gcc
CXX = i686-w64-mingw32-g++
WINDRES = i686-w64-mingw32-windres
GIT_TAG := $(shell git describe --abbrev=0 --tags)
CFLAGS += -O3 -flto
CFLAGS += -Wall -Wno-unused-value -Wno-format -I. -I.. -Ilibwebp -Ilibwebp/src -DGIT_TAG=\"$(GIT_TAG)\" -DNDEBUG -DWIN32 -D_WIN32 -D_WINDOWS 
CFLAGS += -D_USRDLL -DMINGW_HAS_SECURE_API -DUNICODE -D_UNICODE -DNO_STRICT -DCMAKE_INTDIR=\"Release\"  -DWEBP_HAVE_SSE2 -DWEBP_HAVE_SSE41
LDFLAGS += -static -static-libstdc++ -static-libgcc -shared -Wl,--kill-at
LDLIBS +=

%.o: %.c
	@printf '\t%s %s\n' CC $<
	$(CC) -c $(CFLAGS) -o $@ $<

%.o: %.cpp
	@printf '\t%s %s\n' CXX $<
	$(CXX) -c $(CFLAGS) -o $@ $<

%.o: %.rc
	@printf '\t%s %s\n' WINDRES $<
	$(WINDRES) --codepage=65001 $< $@

WEBP_SOURCES += libwebp/src/dec/alpha_dec.c libwebp/src/dec/buffer_dec.c libwebp/src/dec/frame_dec.c libwebp/src/dec/idec_dec.c libwebp/src/dec/io_dec.c libwebp/src/dec/quant_dec.c libwebp/src/dec/tree_dec.c libwebp/src/dec/vp8_dec.c libwebp/src/dec/vp8l_dec.c libwebp/src/dec/webp_dec.c libwebp/src/dsp/alpha_processing.c libwebp/src/dsp/cpu.c libwebp/src/dsp/dec.c libwebp/src/dsp/dec_clip_tables.c libwebp/src/dsp/filters.c libwebp/src/dsp/lossless.c libwebp/src/dsp/rescaler.c libwebp/src/dsp/upsampling.c libwebp/src/dsp/yuv.c libwebp/src/dsp/cost.c libwebp/src/dsp/enc.c libwebp/src/dsp/lossless_enc.c libwebp/src/dsp/ssim.c libwebp/src/enc/alpha_enc.c libwebp/src/enc/analysis_enc.c libwebp/src/enc/backward_references_cost_enc.c libwebp/src/enc/backward_references_enc.c libwebp/src/enc/config_enc.c libwebp/src/enc/cost_enc.c libwebp/src/enc/filter_enc.c libwebp/src/enc/frame_enc.c libwebp/src/enc/histogram_enc.c libwebp/src/enc/iterator_enc.c libwebp/src/enc/near_lossless_enc.c libwebp/src/enc/picture_enc.c libwebp/src/enc/picture_csp_enc.c libwebp/src/enc/picture_psnr_enc.c libwebp/src/enc/picture_rescale_enc.c libwebp/src/enc/picture_tools_enc.c libwebp/src/enc/predictor_enc.c libwebp/src/enc/quant_enc.c libwebp/src/enc/syntax_enc.c libwebp/src/enc/token_enc.c libwebp/src/enc/tree_enc.c libwebp/src/enc/vp8l_enc.c libwebp/src/enc/webp_enc.c libwebp/src/demux/anim_decode.c libwebp/src/demux/demux.c libwebp/src/mux/anim_encode.c libwebp/src/mux/muxedit.c libwebp/src/mux/muxinternal.c libwebp/src/mux/muxread.c libwebp/src/utils/bit_reader_utils.c libwebp/src/utils/color_cache_utils.c libwebp/src/utils/filters_utils.c libwebp/src/utils/huffman_utils.c libwebp/src/utils/quant_levels_dec_utils.c libwebp/src/utils/rescaler_utils.c libwebp/src/utils/random_utils.c libwebp/src/utils/thread_utils.c libwebp/src/utils/utils.c libwebp/src/utils/bit_writer_utils.c libwebp/src/utils/huffman_encode_utils.c libwebp/src/utils/quant_levels_utils.c
WEBP_SSE2_SOURCES += libwebp/src/dsp/alpha_processing_sse2.c libwebp/src/dsp/dec_sse2.c libwebp/src/dsp/filters_sse2.c libwebp/src/dsp/lossless_sse2.c libwebp/src/dsp/rescaler_sse2.c libwebp/src/dsp/upsampling_sse2.c libwebp/src/dsp/yuv_sse2.c libwebp/src/dsp/cost_sse2.c libwebp/src/dsp/enc_sse2.c libwebp/src/dsp/lossless_enc_sse2.c libwebp/src/dsp/ssim_sse2.c
WEBP_SSE41_SOURCES += libwebp/src/dsp/alpha_processing_sse41.c libwebp/src/dsp/dec_sse41.c libwebp/src/dsp/upsampling_sse41.c libwebp/src/dsp/yuv_sse41.c libwebp/src/dsp/enc_sse41.c libwebp/src/dsp/lossless_enc_sse41.c

SOURCES := ../tp_stub.cpp dllmain.cpp krglhwebp.rc $(WEBP_SOURCES) $(WEBP_SSE2_SOURCES) $(WEBP_SSE41_SOURCES)
OBJECTS := $(SOURCES:.c=.o)
OBJECTS := $(OBJECTS:.cpp=.o)
OBJECTS := $(OBJECTS:.rc=.o)

$(WEBP_SSE2_SOURCES:.c=.o): CFLAGS += -msse2
$(WEBP_SSE41_SOURCES:.c=.o): CFLAGS += -msse4.1

BINARY ?= krglhwebp_unstripped.dll
BINARY_STRIPPED ?= krglhwebp.dll
ARCHIVE ?= krglhwebp.$(GIT_TAG).7z

all: $(BINARY_STRIPPED)

archive: $(ARCHIVE)

clean:
	rm -f $(OBJECTS) $(BINARY) $(BINARY_STRIPPED) $(ARCHIVE)

$(ARCHIVE): $(BINARY_STRIPPED) 
	rm -f $(ARCHIVE)
	7z a $@ $^

$(BINARY_STRIPPED): $(BINARY)
	i686-w64-mingw32-strip -o $@ $^

$(BINARY): $(OBJECTS) 
	@printf '\t%s %s\n' LNK $@
	$(CXX) $(CFLAGS) $(LDFLAGS)  -o $@ $^  $(LDLIBS)
