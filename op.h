/*
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

#ifndef SHA_OP_H
#define SHA_OP_H

static inline unsigned int rol32(unsigned int word, unsigned int shift)
{
        return (word << shift) | (word >> (32 - shift));
}

static inline unsigned int ror32(unsigned int word, unsigned int shift)
{
	return (word >> shift) | (word << (32 - shift));
}

static inline unsigned int swap32(unsigned int a)
{
	return (a << 24) | ((a & 0xff00) << 8) | ((a >> 8) & 0xff00) | (a >> 24);
}

/* big endian to cpu */
#include <endian.h>
#if LITTLE_ENDIAN == BYTE_ORDER
#define be32_to_cpu(a) swap32(a)
#define cpu_to_be32(a) swap32(a)
#elif BIG_ENDIAN == BYTE_ORDER
#define be32_to_cpu(a) (a)
#define cpu_to_be32(a) (a)
#else
#error "endian not supported"
#endif

#endif /* !SHA_OP_H */
