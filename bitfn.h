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
 * SHA implementation low level operation
 */

#ifndef BITFN_H
#define BITFN_H
#include <stdint.h>

static inline unsigned int rol32(unsigned int word, unsigned int shift)
{
        return (word << shift) | (word >> (32 - shift));
}

static inline unsigned int ror32(unsigned int word, unsigned int shift)
{
	return (word >> shift) | (word << (32 - shift));
}

static inline uint64_t rol64(uint64_t word, unsigned int shift)
{
        return (word << shift) | (word >> (64 - shift));
}

static inline uint64_t ror64(uint64_t word, unsigned int shift)
{
	return (word >> shift) | (word << (64 - shift));
}

#if (defined(__i386__) || defined(__x86_64__)) && !defined(NO_INLINE_ASM)
static inline unsigned int swap32(unsigned int a)
{
	asm ("bswap %0" : "=r" (a) : "0" (a));
	return a;
}
#else
static inline unsigned int swap32(unsigned int a)
{
	return (a << 24) | ((a & 0xff00) << 8) | ((a >> 8) & 0xff00) | (a >> 24);
}
#endif

#if defined(__x86_64__) && !defined(NO_INLINE_ASM)
static inline uint64_t swap64(uint64_t a)
{
	asm ("bswap %0" : "=r" (a) : "0" (a));
	return a;
}
#else
static inline uint64_t swap64(uint64_t a)
{
	return ((uint64_t) swap32((unsigned int) (a >> 32))) |
	       (((uint64_t) swap32((unsigned int) a)) << 32);
}
#endif

/* big endian to cpu */
#ifdef __APPLE__
#include <architecture/byte_order.h>
#elif WIN32
/* nothing */
#else
#include <endian.h>
#endif

#if LITTLE_ENDIAN == BYTE_ORDER
#define be32_to_cpu(a) swap32(a)
#define cpu_to_be32(a) swap32(a)
#define be64_to_cpu(a) swap64(a)
#define cpu_to_be64(a) swap64(a)
#elif BIG_ENDIAN == BYTE_ORDER
#define be32_to_cpu(a) (a)
#define cpu_to_be32(a) (a)
#define be64_to_cpu(a) (a)
#define cpu_to_be64(a) (a)
#else
#error "endian not supported"
#endif

#endif /* !BITFN_H */
