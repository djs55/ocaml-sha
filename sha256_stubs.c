/**
 *	Copyright (C) 2006 Vincent Hanquez <tab@snarc.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published
 * by the Free Software Foundation; version 2 only.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * SHA256 implementation
 */

/* this part implement the C part of the algorithm */
#include <string.h>
#include <stdio.h>
#include "op.h"

struct sha256_ctx
{
	unsigned int h[8];
	unsigned char buf[128];
	unsigned long long sz;
};

typedef struct { unsigned int digest[8]; } sha256_digest;

/**
 * sha256_init - Init SHA256 context
 */
static void sha256_init(struct sha256_ctx *ctx)
{
	memset(ctx, 0, sizeof(*ctx));

	ctx->h[0] = 0x6a09e667;
	ctx->h[1] = 0xbb67ae85;
	ctx->h[2] = 0x3c6ef372;
	ctx->h[3] = 0xa54ff53a;
	ctx->h[4] = 0x510e527f;
	ctx->h[5] = 0x9b05688c;
	ctx->h[6] = 0x1f83d9ab;
	ctx->h[7] = 0x5be0cd19;
}

/* 232 times the cube root of the first 64 primes 2..311 */
static const unsigned int k[] = {
	0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1,
	0x923f82a4, 0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3,
	0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786,
	0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
	0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147,
	0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13,
	0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
	0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
	0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a,
	0x5b9cca4f, 0x682e6ff3, 0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208,
	0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2 };

static inline unsigned int Ch(unsigned int x, unsigned int y, unsigned int z)
{
	return z ^ (x & (y ^ z));
}

static inline unsigned int Maj(unsigned int x, unsigned int y, unsigned int z)
{
	return (x & y) | (z & (x | y));
}

#define e0(x)       (ror32(x, 2) ^ ror32(x,13) ^ ror32(x,22))
#define e1(x)       (ror32(x, 6) ^ ror32(x,11) ^ ror32(x,25))
#define s0(x)       (ror32(x, 7) ^ ror32(x,18) ^ (x >> 3))
#define s1(x)       (ror32(x,17) ^ ror32(x,19) ^ (x >> 10))

/**
 * sha256_do_chunk - Process a block through SHA256
 */
static void sha256_do_chunk(unsigned char __W[], unsigned int H[])
{
	unsigned int a, b, c, d, e, f, g, h, t1, t2;
	unsigned int W[64];
	int i;

	for (i = 0; i < 16; i++)
		W[i] = be32_to_cpu(((unsigned int *) __W)[i]);

	for (i = 16; i < 64; i++)
		W[i] = s1(W[i - 2]) + W[i - 7] + s0(W[i - 15]) + W[i - 16];

	a = H[0];
	b = H[1];
	c = H[2];
	d = H[3];
	e = H[4];
	f = H[5];
	g = H[6];
	h = H[7];

#define T(a, b, c, d, e, f, g, h, k, w)			\
	do {						\
		t1 = h + e1(e) + Ch(e, f, g) + k + w;	\
		t2 = e0(a) + Maj(a, b, c);		\
		d += t1;				\
		h = t1 + t2;				\
	} while (0)

#define PASS(i)							\
	do {							\
		T(a, b, c, d, e, f, g, h, k[i + 0], W[i + 0]);	\
		T(h, a, b, c, d, e, f, g, k[i + 1], W[i + 1]);	\
		T(g, h, a, b, c, d, e, f, k[i + 2], W[i + 2]);	\
		T(f, g, h, a, b, c, d, e, k[i + 3], W[i + 3]);	\
		T(e, f, g, h, a, b, c, d, k[i + 4], W[i + 4]);	\
		T(d, e, f, g, h, a, b, c, k[i + 5], W[i + 5]);	\
		T(c, d, e, f, g, h, a, b, k[i + 6], W[i + 6]);	\
		T(b, c, d, e, f, g, h, a, k[i + 7], W[i + 7]);	\
	} while (0)

	PASS(0);
	PASS(8);
	PASS(16);
	PASS(24);
	PASS(32);
	PASS(40);
	PASS(48);
	PASS(56);

#undef T
#undef PASS

	H[0] += a;
	H[1] += b;
	H[2] += c;
	H[3] += d;
	H[4] += e;
	H[5] += f;
	H[6] += g;
	H[7] += h;
}

/**
 * sha256_update - Update the SHA256 context values with length bytes of data
 */
static void sha256_update(struct sha256_ctx *ctx, unsigned char *data, int len)
{
	unsigned int index, to_fill;

	/* check for partial buffer */
	index = (unsigned int) (ctx->sz & 0x3f);
	to_fill = 64 - index;

	ctx->sz += len;

	/* process partial buffer if there's enough data to make a block */
	if (index && len >= to_fill) {
		memcpy(ctx->buf + index, data, to_fill);
		sha256_do_chunk(ctx->buf, ctx->h);
		len -= to_fill;
		data += to_fill;
		index = 0;
	}

	/* process as much 64-block as possible */
	for (; len >= 64; len -= 64, data += 64)
		sha256_do_chunk(data, ctx->h);

	/* append data into buf */
	if (len)
		memcpy(ctx->buf + index, data, len);
}

/**
 * sha256_finalize - Finalize the context and create the SHA256 digest
 */
static void sha256_finalize(struct sha256_ctx *ctx, sha256_digest *out)
{
	static unsigned char padding[64] = { 0x80, };
	unsigned int bits[2];
	unsigned int i, index, padlen;

	/* cpu -> big endian */
	bits[0] = cpu_to_be32((unsigned int) (ctx->sz >> 29));
	bits[1] = cpu_to_be32((unsigned int) (ctx->sz << 3));

	/* pad out to 56 */
	index = (unsigned int) (ctx->sz & 0x3f);
	padlen = (index < 56) ? (56 - index) : ((64 + 56) - index);
	sha256_update(ctx, padding, padlen);

	/* append length */
	sha256_update(ctx, (unsigned char *) bits, sizeof(bits));

	/* store to digest */
	for (i = 0; i < 8; i++)
		out->digest[i] = cpu_to_be32(ctx->h[i]);
}

/**
 * sha256_to_hex - Transform the SHA256 digest into a readable data
 */
static inline void sha256_to_hex(sha256_digest *digest, char *out)
{
	char *p;
	int i;

	for (p = out, i = 0; i < 8; i++, p += 8)
		snprintf(p, 9, "%08x", be32_to_cpu(digest->digest[i]));
}

#include <unistd.h>
#include <fcntl.h>

static inline int sha256_file(char *filename, sha256_digest *digest)
{
	#define BLKSIZE 4096
	unsigned char buf[BLKSIZE];
	int fd; ssize_t n;
	struct sha256_ctx ctx;

	fd = open(filename, O_RDONLY);
	if (fd == -1)
		return 1;
	sha256_init(&ctx);
	while ((n = read(fd, buf, BLKSIZE)) > 0)
		sha256_update(&ctx, buf, n);
	if (n == 0)
		sha256_finalize(&ctx, digest);
	close(fd);
	return n < 0;
	#undef BLKSIZE
}

/* this part implement the OCaml binding */
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>

#define GET_CTX_STRUCT(a) ((struct sha256_ctx *) a)

CAMLexport value stub_sha256_init(value unit)
{
	CAMLparam1(unit);
	CAMLlocal1(result);

	result = caml_alloc(sizeof(struct sha256_ctx), Abstract_tag);
	sha256_init(GET_CTX_STRUCT(result));

	CAMLreturn(result);
}

CAMLprim value stub_sha256_update(value ctx, value data, value ofs, value len)
{
	CAMLparam4(ctx, data, ofs, len);

	sha256_update(GET_CTX_STRUCT(ctx), (unsigned char *) data
	                                   + Int_val(ofs), Int_val(len));
	CAMLreturn(Val_unit);
}

CAMLprim value stub_sha256_finalize(value ctx)
{
	CAMLparam1(ctx);
	CAMLlocal1(result);

	result = caml_alloc(sizeof(sha256_digest), Abstract_tag);
	sha256_finalize(GET_CTX_STRUCT(ctx), (sha256_digest *) result);

	CAMLreturn(result);
}

CAMLprim value stub_sha256_file(value name)
{
	CAMLparam1(name);
	CAMLlocal1(result);

	result = caml_alloc(sizeof(sha256_digest), Abstract_tag);
	if (sha256_file(String_val(name), (sha256_digest *) result))
		caml_failwith("file error");

	CAMLreturn(result);
}

CAMLprim value stub_sha256_to_hex(value digest)
{
	CAMLparam1(digest);
	CAMLlocal1(result);

	result = caml_alloc_string(64);
	sha256_to_hex((sha256_digest *) digest, String_val(result));

	CAMLreturn(result);
}
