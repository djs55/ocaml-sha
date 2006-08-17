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
 * SHA1 implementation as describe in wikipedia.
 */

/* this part implement the C part of the algorithm */
#include <string.h>
#include <stdio.h>

struct sha1_ctx
{
	unsigned int h[5];
	unsigned int w[80];
	int len;
	unsigned int sz_high;
	unsigned int sz_low;
};

typedef struct { unsigned char digest[20]; } sha1_digest;

/**
 * sha1_init - Init SHA1 context
 */
static void sha1_init(struct sha1_ctx *ctx)
{
	memset(ctx, 0, sizeof(*ctx));

	/* initialize H */
	ctx->h[0] = 0x67452301;
	ctx->h[1] = 0xEFCDAB89;
	ctx->h[2] = 0x98BADCFE;
	ctx->h[3] = 0x10325476;
	ctx->h[4] = 0xC3D2E1F0;
}

static inline unsigned int rol32(unsigned int word, unsigned int shift)
{
        return (word << shift) | (word >> (32 - shift));
}

#define f1(x, y, z)   (z ^ (x & (y ^ z)))         /* x ? y : z */
#define f2(x, y, z)   (x ^ y ^ z)                 /* XOR */
#define f3(x, y, z)   ((x & y) + (z & (x ^ y)))   /* majority */
#define f4(x, y, z)   f2(x, y, z)

#define K1  0x5A827999L                 /* Rounds  0-19: sqrt(2) * 2^30 */
#define K2  0x6ED9EBA1L                 /* Rounds 20-39: sqrt(3) * 2^30 */
#define K3  0x8F1BBCDCL                 /* Rounds 40-59: sqrt(5) * 2^30 */
#define K4  0xCA62C1D6L                 /* Rounds 60-79: sqrt(10) * 2^30 */

#define R(a, b, c, d, e, f, k, w)  e += rol32(a, 5) + f(b, c, d) + k + w; \
                                   b = rol32(b, 30)

static inline void sha1_do_chunk(unsigned int w[], unsigned int h[])
{
	unsigned int a, b, c, d, e, i;

	for (i = 16; i <= 79; i++)
		w[i] = rol32(w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16], 1);

	a = h[0];
	b = h[1];
	c = h[2];
	d = h[3];
	e = h[4];

	/* following unrolled from:
	 *	for (i = 0; i < 20; i++) {
	 *		t = f1(b, c, d) + K1 + rol32(a, 5) + e + w[i];
	 *		e = d; d = c; c = rol32(b, 30); b = a; a = t;
	 *	}
	 */
	R(a, b, c, d, e, f1, K1, w[0]);
	R(e, a, b, c, d, f1, K1, w[1]);
	R(d, e, a, b, c, f1, K1, w[2]);
	R(c, d, e, a, b, f1, K1, w[3]);
	R(b, c, d, e, a, f1, K1, w[4]);
	R(a, b, c, d, e, f1, K1, w[5]);
	R(e, a, b, c, d, f1, K1, w[6]);
	R(d, e, a, b, c, f1, K1, w[7]);
	R(c, d, e, a, b, f1, K1, w[8]);
	R(b, c, d, e, a, f1, K1, w[9]);
	R(a, b, c, d, e, f1, K1, w[10]);
	R(e, a, b, c, d, f1, K1, w[11]);
	R(d, e, a, b, c, f1, K1, w[12]);
	R(c, d, e, a, b, f1, K1, w[13]);
	R(b, c, d, e, a, f1, K1, w[14]);
	R(a, b, c, d, e, f1, K1, w[15]);
	R(e, a, b, c, d, f1, K1, w[16]);
	R(d, e, a, b, c, f1, K1, w[17]);
	R(c, d, e, a, b, f1, K1, w[18]);
	R(b, c, d, e, a, f1, K1, w[19]);

	/* following unrolled from:
	 *	for (i = 20; i < 40; i++) {
	 *		t = f2(b, c, d) + K2 + rol32(a, 5) + e + w[i];
	 *		e = d; d = c; c = rol32(b, 30); b = a; a = t;
	 *	}
	 */

	R(a, b, c, d, e, f2, K2, w[20]);
	R(e, a, b, c, d, f2, K2, w[21]);
	R(d, e, a, b, c, f2, K2, w[22]);
	R(c, d, e, a, b, f2, K2, w[23]);
	R(b, c, d, e, a, f2, K2, w[24]);
	R(a, b, c, d, e, f2, K2, w[25]);
	R(e, a, b, c, d, f2, K2, w[26]);
	R(d, e, a, b, c, f2, K2, w[27]);
	R(c, d, e, a, b, f2, K2, w[28]);
	R(b, c, d, e, a, f2, K2, w[29]);
	R(a, b, c, d, e, f2, K2, w[30]);
	R(e, a, b, c, d, f2, K2, w[31]);
	R(d, e, a, b, c, f2, K2, w[32]);
	R(c, d, e, a, b, f2, K2, w[33]);
	R(b, c, d, e, a, f2, K2, w[34]);
	R(a, b, c, d, e, f2, K2, w[35]);
	R(e, a, b, c, d, f2, K2, w[36]);
	R(d, e, a, b, c, f2, K2, w[37]);
	R(c, d, e, a, b, f2, K2, w[38]);
	R(b, c, d, e, a, f2, K2, w[39]);

	/* following unrolled from:
	 *	for (i = 40; i < 60; i++) {
	 *		t = f3(b, c, d) + K3 + rol32(a, 5) + e + w[i];
	 *		e = d; d = c; c = rol32(b, 30); b = a; a = t;
	 *	}
	 */

	R(a, b, c, d, e, f3, K3, w[40]);
	R(e, a, b, c, d, f3, K3, w[41]);
	R(d, e, a, b, c, f3, K3, w[42]);
	R(c, d, e, a, b, f3, K3, w[43]);
	R(b, c, d, e, a, f3, K3, w[44]);
	R(a, b, c, d, e, f3, K3, w[45]);
	R(e, a, b, c, d, f3, K3, w[46]);
	R(d, e, a, b, c, f3, K3, w[47]);
	R(c, d, e, a, b, f3, K3, w[48]);
	R(b, c, d, e, a, f3, K3, w[49]);
	R(a, b, c, d, e, f3, K3, w[50]);
	R(e, a, b, c, d, f3, K3, w[51]);
	R(d, e, a, b, c, f3, K3, w[52]);
	R(c, d, e, a, b, f3, K3, w[53]);
	R(b, c, d, e, a, f3, K3, w[54]);
	R(a, b, c, d, e, f3, K3, w[55]);
	R(e, a, b, c, d, f3, K3, w[56]);
	R(d, e, a, b, c, f3, K3, w[57]);
	R(c, d, e, a, b, f3, K3, w[58]);
	R(b, c, d, e, a, f3, K3, w[59]);

	/* following unrolled from:
	 *	for (i = 60; i < 80; i++) {
	 *		t = f2(b, c, d) + K4 + rol32(a, 5) + e + w[i];
	 *		e = d; d = c; c = rol32(b, 30); b = a; a = t;
	 *	}
	 */
	R(a, b, c, d, e, f4, K4, w[60]);
	R(e, a, b, c, d, f4, K4, w[61]);
	R(d, e, a, b, c, f4, K4, w[62]);
	R(c, d, e, a, b, f4, K4, w[63]);
	R(b, c, d, e, a, f4, K4, w[64]);
	R(a, b, c, d, e, f4, K4, w[65]);
	R(e, a, b, c, d, f4, K4, w[66]);
	R(d, e, a, b, c, f4, K4, w[67]);
	R(c, d, e, a, b, f4, K4, w[68]);
	R(b, c, d, e, a, f4, K4, w[69]);
	R(a, b, c, d, e, f4, K4, w[70]);
	R(e, a, b, c, d, f4, K4, w[71]);
	R(d, e, a, b, c, f4, K4, w[72]);
	R(c, d, e, a, b, f4, K4, w[73]);
	R(b, c, d, e, a, f4, K4, w[74]);
	R(a, b, c, d, e, f4, K4, w[75]);
	R(e, a, b, c, d, f4, K4, w[76]);
	R(d, e, a, b, c, f4, K4, w[77]);
	R(c, d, e, a, b, f4, K4, w[78]);
	R(b, c, d, e, a, f4, K4, w[79]);

	h[0] += a;
	h[1] += b;
	h[2] += c;
	h[3] += d;
	h[4] += e;
}

/**
 * sha1_update - Update the SHA1 context values with lenght bytes of data
 */
static void sha1_update(struct sha1_ctx *ctx, unsigned char *data,
		int ofs, int len)
{
	int i;

	for (i = ofs; i < len; i++) {
		ctx->w[ctx->len / 4] <<= 8;
		ctx->w[ctx->len / 4] |= (unsigned int) data[i];
		ctx->len += 1;
		if ((ctx->len % 64) == 0) {
			sha1_do_chunk(ctx->w, ctx->h);
			ctx->len = 0;
		}
		ctx->sz_low += 8;
		ctx->sz_high += (ctx->sz_low < 8);
	}
}

/**
 * sha1_finalize - Finalize the context and create the SHA1 digest
 */
static void sha1_finalize(struct sha1_ctx *ctx, sha1_digest *out)
{
	unsigned char pad1 = 0x80;
	unsigned char pad0 = 0x00;
	unsigned char padlen[8];
	int i;

	/* add padding and update data with it */
	padlen[0] = (unsigned char)((ctx->sz_high >> 24) & 255);
	padlen[1] = (unsigned char)((ctx->sz_high >> 16) & 255);
	padlen[2] = (unsigned char)((ctx->sz_high >> 8) & 255);
	padlen[3] = (unsigned char)((ctx->sz_high >> 0) & 255);
	padlen[4] = (unsigned char)((ctx->sz_low >> 24) & 255);
	padlen[5] = (unsigned char)((ctx->sz_low >> 16) & 255);
	padlen[6] = (unsigned char)((ctx->sz_low >> 8) & 255);
	padlen[7] = (unsigned char)((ctx->sz_low >> 0) & 255);

	sha1_update(ctx, &pad1, 0, 1);
	while (ctx->len != 56)
		sha1_update(ctx, &pad0, 0, 1);
	sha1_update(ctx, padlen, 0, 8);

	/* output hash */
	for (i = 0; i < 20; i++) {
		out->digest[i] = (unsigned char)(ctx->h[i / 4] >> 24);
		ctx->h[i / 4] <<= 8;
	}
}

/**
 * sha1_to_hex - Transform the SHA1 digest into a readable data
 */
static void sha1_to_hex(sha1_digest *digest, char *out)
{
	char *p;
	int i;

	for (p = out, i = 0; i < 20; i++, p += 2)
		snprintf(p, 3, "%02x", digest->digest[i]);
}

/* this part implement the OCaml binding */
#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/custom.h>
#include <caml/fail.h>

#define GET_CTX_STRUCT(a) ((struct sha1_ctx *) a)

CAMLexport value stub_sha1_init(value unit)
{
	CAMLparam1(unit);
	CAMLlocal1(result);

	result = caml_alloc(sizeof(struct sha1_ctx), Abstract_tag);
	sha1_init(GET_CTX_STRUCT(result));

	CAMLreturn(result);
}

CAMLprim value stub_sha1_update(value ctx, value data, value ofs, value len)
{
	CAMLparam4(ctx, data, ofs, len);

	sha1_update(GET_CTX_STRUCT(ctx), (unsigned char *) data,
			Int_val(ofs), Int_val(len));

	CAMLreturn(Val_unit);
}

CAMLprim value stub_sha1_finalize(value ctx)
{
	CAMLparam1(ctx);
	CAMLlocal1(result);

	result = caml_alloc(sizeof(sha1_digest), Abstract_tag);
	sha1_finalize(GET_CTX_STRUCT(ctx), (sha1_digest *) result);

	CAMLreturn(result);
}

CAMLprim value stub_sha1_to_hex(value digest)
{
	CAMLparam1(digest);
	CAMLlocal1(result);

	result = caml_alloc_string(40);
	sha1_to_hex((sha1_digest *) digest, String_val(result));

	CAMLreturn(result);
}
