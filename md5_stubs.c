/*
 *	Copyright (c) 2017 Christopher Zimmermann <madroach@gmerlin.de>
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
 *
 * md5 stub code linking to the md5 backend in the OCaml runtime.
 */

#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/alloc.h>
#include <caml/bigarray.h>
#include <caml/threads.h>
#include <caml/fail.h>

#include <fcntl.h>
#include <unistd.h>
#include <string.h>

#include "md5.h"

#define GET_CTX_STRUCT(a) ((struct MD5Context *) a)

#define BLKSIZE 4096

static inline int md5_file(char *filename, unsigned char *digest)
{
	unsigned char buf[BLKSIZE];
	int fd; ssize_t n;
	struct MD5Context ctx;

#ifdef WIN32
	fd = open(filename, O_RDONLY);
#else
	fd = open(filename, O_RDONLY | O_CLOEXEC);
#endif
	if (fd == -1)
		return 1;
	caml_MD5Init(&ctx);
	while ((n = read(fd, buf, BLKSIZE)) > 0)
		caml_MD5Update(&ctx, buf, n);
	if (n == 0)
		caml_MD5Final(digest, &ctx);
	close(fd);
	return n < 0;
}

CAMLprim value stub_md5_init(value unit)
{
	value ctx;

	ctx = caml_alloc_small(sizeof(struct MD5Context), Abstract_tag);
	caml_MD5Init(GET_CTX_STRUCT(ctx));

	return(ctx);
}

CAMLprim value stub_md5_update(value ctx, value data, value ofs, value len)
{
	caml_MD5Update(GET_CTX_STRUCT(ctx),
		(unsigned char *) data + Long_val(ofs), Long_val(len));

	return(Val_unit);
}

CAMLprim value stub_md5_update_bigarray(value ctx, value buf, value pos, value len)
{
	CAMLparam4(ctx, buf, pos, len);
	struct MD5Context ctx_dup = *GET_CTX_STRUCT(ctx);
	unsigned char *data = Data_bigarray_val(buf);

	caml_release_runtime_system();
	caml_MD5Update(&ctx_dup,
		data + Long_val(pos),
		Long_val(len));
	caml_acquire_runtime_system();

	*GET_CTX_STRUCT(ctx) = ctx_dup;
	CAMLreturn(Val_unit);
}

CAMLprim value stub_md5_update_fd(value ctx, value fd, value len)
{
	CAMLparam3(ctx, fd, len);

	char buf[BLKSIZE];

	struct MD5Context ctx_dup = *GET_CTX_STRUCT(ctx);

	intnat ret, rest = Long_val(len);

	caml_release_runtime_system();
	do {
	    ret = rest < sizeof(buf) ? rest : sizeof(buf);
	    ret = read(Long_val(fd), buf, ret);
	    if (ret <= 0) break;
	    rest -= ret;
	    caml_MD5Update(&ctx_dup, buf, ret);
	} while (ret > 0 && rest > 0);
	caml_acquire_runtime_system();

	if (ret < 0)
	    caml_failwith("read error");

	*GET_CTX_STRUCT(ctx) = ctx_dup;
	CAMLreturn(Val_long(Long_val(len) - rest));
}

CAMLprim value stub_md5_file(value name)
{
	CAMLparam1(name);
	CAMLlocal1(result);

	unsigned char digest[16];
	const int len = caml_string_length(name);
	char *name_dup = alloca(len);
	memcpy(name_dup, String_val(name), len);
	name_dup[len] = '\0';

	caml_release_runtime_system();
	if (md5_file(name_dup, digest)) {
	    caml_acquire_runtime_system();
	    caml_failwith("file error");
	}
	caml_acquire_runtime_system();
	result = caml_alloc_string(sizeof(digest));
	memcpy(String_val(result), &digest, sizeof(digest));

	CAMLreturn(result);
}

CAMLprim value stub_md5_finalize(value ctx)
{
	CAMLparam1(ctx);
	value result;

	result = caml_alloc_string(16);
	caml_MD5Final(
		(unsigned char *)Bp_val(result),
		GET_CTX_STRUCT(ctx));

	CAMLreturn(result);
}
