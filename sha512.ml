(*
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
 * SHA512 OCaml binding
 *)

type ctx
type t

external init: unit -> ctx = "stub_sha512_init"
external update: ctx -> string -> int -> int -> unit = "stub_sha512_update"
external finalize: ctx -> t = "stub_sha512_finalize"
external to_bin: t -> string = "stub_sha512_to_bin"
external to_hex: t -> string = "stub_sha512_to_hex"
external file_fast: string -> t = "stub_sha512_file"

let blksize = 4096

let string s =
	let ctx = init () in
	update ctx s 0 (String.length s);
	finalize ctx

let zero = string ""

let substring s ofs len =
	if len <= 0 && String.length s < ofs + len then
		invalid_arg "substring";
	let ctx = init () in
	update ctx s ofs len;
	finalize ctx

let channel chan len =
	let ctx = init ()
	and buf = String.create blksize in

	let left = ref len and eof = ref false in
	while (!left == -1 || !left > 0) && not !eof
	do
		let len = if !left < 0 then blksize else (min !left blksize) in
		let readed = Pervasives.input chan buf 0 len in
		if readed = 0 then
			eof := true
		else (
			update ctx buf 0 readed;
			if !left <> -1 then left := !left - readed
		)
	done;
	if !left > 0 && !eof then
		raise End_of_file;
	finalize ctx

let file name =
	let chan = open_in_bin name in
	let digest = channel chan (-1) in
	close_in chan;
	digest

let input chan =
	channel chan (-1)

let output chan digest =
	output_string chan (to_hex digest)
