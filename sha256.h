/*
 	Copyright (C) 2006-2009 Vincent Hanquez <tab@snarc.org>
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
 * SHA256 implementation
 */
#ifndef SHA256_H
#define SHA256_H

struct sha256_ctx
{
	unsigned int h[8];
	unsigned char buf[128];
	unsigned long long sz;
};

typedef struct { unsigned int digest[8]; } sha256_digest;

void sha256_init(struct sha256_ctx *ctx);
void sha256_update(struct sha256_ctx *ctx, unsigned char *data, int len);
void sha256_finalize(struct sha256_ctx *ctx, sha256_digest *out);
void sha256_to_bin(sha256_digest *digest, char *out);
void sha256_to_hex(sha256_digest *digest, char *out);

#endif
