(*
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
 * SHA256 OCaml binding
 *)

module Sha256ops = struct
type ctx
type t

external init: unit -> ctx = "stub_sha256_init"
external update: ctx -> string -> int -> int -> unit = "stub_sha256_update"
external finalize: ctx -> t = "stub_sha256_finalize"
external to_hex: t -> string = "stub_sha256_to_hex"
external file_fast: string -> t = "stub_sha256_file"

end

include Sha.Sha(Sha256ops)
