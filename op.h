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

#endif /* !SHA_OP_H */
