/*
 *	Copyright (C) 2006-2009 Vincent Hanquez <tab@snarc.org>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; version 2.1 or version 3.0 only.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * SHA512 implementation
 */
#ifndef SHA512_H
#define SHA512_H

#include <stdint.h>

struct sha512_ctx
{
	uint64_t h[8];
	unsigned char buf[128];
	uint64_t sz[2];
};

typedef struct { uint64_t digest[8]; } sha512_digest;

void sha512_init(struct sha512_ctx *ctx);
void sha512_update(struct sha512_ctx *ctx, unsigned char *data, int len);
void sha512_finalize(struct sha512_ctx *ctx, sha512_digest *out);
void sha512_to_bin(sha512_digest *digest, char *out);
void sha512_to_hex(sha512_digest *digest, char *out);

#endif
