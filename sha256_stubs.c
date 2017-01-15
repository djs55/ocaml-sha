/*
 *	Copyright (C) 2006-2009 Vincent Hanquez <tab@snarc.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 * ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 * SHA256 implementation
 */

#define _GNU_SOURCE
#ifdef _MSC_VER
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#define alloca _alloca
#else
#include <unistd.h>
#endif
#include <string.h>
#include <fcntl.h>
#include <string.h>
#include "sha256.h"

static inline int sha256_file(char *filename, sha256_digest *digest)
{
	#define BLKSIZE 4096
	unsigned char buf[BLKSIZE];
	int fd; ssize_t n;
	struct sha256_ctx ctx;

#ifdef WIN32
	fd = open(filename, O_RDONLY);
#else
	fd = open(filename, O_RDONLY | O_CLOEXEC);
#endif
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
#include <caml/bigarray.h>
#include <caml/threads.h>

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

CAMLprim value stub_sha256_update_bigarray(value ctx, value buf)
{
	CAMLparam2(ctx, buf);
	struct sha256_ctx ctx_dup;
	unsigned char *data = Data_bigarray_val(buf);
	size_t len = Bigarray_val(buf)->dim[0];

	ctx_dup = *GET_CTX_STRUCT(ctx);
	caml_release_runtime_system();
	sha256_update(&ctx_dup, data, len);
	caml_acquire_runtime_system();
	*GET_CTX_STRUCT(ctx) = ctx_dup;

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

#ifndef strdupa
#define strdupa(s) strcpy(alloca(strlen(s)+1),s)
#endif

CAMLprim value stub_sha256_file(value name)
{
	CAMLparam1(name);
	CAMLlocal1(result);

	char *name_dup = strdupa(String_val(name));
	sha256_digest digest;

	caml_release_runtime_system();
	if (sha256_file(name_dup, &digest)) {
	    caml_acquire_runtime_system();
	    caml_failwith("file error");
	}
	caml_acquire_runtime_system();
	result = caml_alloc(sizeof(sha256_digest), Abstract_tag);
	memcpy((sha256_digest *)result, &digest, sizeof(sha256_digest));

	CAMLreturn(result);
}

CAMLprim value stub_sha256_to_bin(value digest)
{
	CAMLparam1(digest);
	CAMLlocal1(result);

	result = caml_alloc_string(32);
	sha256_to_bin((sha256_digest *) digest, String_val(result));

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
