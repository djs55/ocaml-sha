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
 * SHA1 implementation as describe in wikipedia.
 */
#ifndef SHA1_H
#define SHA1_H

struct sha1_ctx
{
	unsigned int h[5];
	unsigned char buf[64];
	unsigned long long sz;
};

typedef struct { unsigned int digest[5]; } sha1_digest;

void sha1_init(struct sha1_ctx *ctx);
void sha1_update(struct sha1_ctx *ctx, unsigned char *data, int len);
void sha1_finalize(struct sha1_ctx *ctx, sha1_digest *out);
void sha1_to_bin(sha1_digest *digest, char *out);
void sha1_to_hex(sha1_digest *digest, char *out);

#endif
