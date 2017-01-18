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

#include "md5.h"

#define GET_CTX_STRUCT(a) ((struct MD5Context *) a)

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
		(unsigned char *) data + Int_val(ofs), Int_val(len));

	return(Val_unit);
}

CAMLprim value stub_md5_update_bigarray(value ctx, value buf)
{
	CAMLparam2(ctx, buf);
	struct MD5Context ctx_dup = *GET_CTX_STRUCT(ctx);
	unsigned char *data = Data_bigarray_val(buf);
	size_t len = Bigarray_val(buf)->dim[0];

	caml_release_runtime_system();
	caml_MD5Update(&ctx_dup, data, len);
	caml_acquire_runtime_system();

	*GET_CTX_STRUCT(ctx) = ctx_dup;
	CAMLreturn(Val_unit);
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
