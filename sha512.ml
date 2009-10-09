(*
 *	Copyright (C) 2006-2008 Vincent Hanquez <tab@snarc.org>
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
 * SHA512 OCaml binding
 *)

module Sha512ops = struct
type ctx
type t

external init: unit -> ctx = "stub_sha512_init"
external update: ctx -> string -> int -> int -> unit = "stub_sha512_update"
external finalize: ctx -> t = "stub_sha512_finalize"
external to_hex: t -> string = "stub_sha512_to_hex"
external file_fast: string -> t = "stub_sha512_file"
end

include Shacommon.Sha(Sha512ops)
