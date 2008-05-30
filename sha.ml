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
 *)

module type SHAOPS = sig
	type ctx
	type t

	val init: unit -> ctx
	val update: ctx -> string -> int -> int -> unit
	val finalize: ctx -> t
	val to_hex: t -> string
	val file_fast: string -> t
end

module Sha = functor(Shaops: SHAOPS) -> struct

type t = Shaops.t

let string s =
	let ctx = Shaops.init () in
	Shaops.update ctx s 0 (String.length s);
	Shaops.finalize ctx

let substring s ofs len =
	if len <= 0 && String.length s < ofs + len then
		invalid_arg "substring";
	let ctx = Shaops.init () in
	Shaops.update ctx s ofs len;
	Shaops.finalize ctx

let channel chan len =
	let ctx = Shaops.init ()
	and buf = String.create 4096 in

	let left = ref len and eof = ref false in
	while (!left == -1 || !left > 0) && not !eof
	do
		let len = if !left < 0 then 4096 else (min !left 4096) in
		let readed = Pervasives.input chan buf 0 len in
		if readed = 0 then
			eof := true
		else (
			Shaops.update ctx buf 0 readed;
			if !left <> -1 then left := !left - readed
		)
	done;
	if !left > 0 && !eof then
		raise End_of_file;
	Shaops.finalize ctx

let file name =
	let chan = open_in_bin name in
	let digest = channel chan (-1) in
	close_in chan;
	digest

let input chan =
	channel chan (-1)

let output chan digest =
	output_string chan (Shaops.to_hex digest)

let to_hex digest = Shaops.to_hex digest

let file_fast file = Shaops.file_fast file

end
