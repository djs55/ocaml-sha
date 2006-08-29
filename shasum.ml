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
 * SHA1sum - test ocaml SHA1 binding
 *)

open Printf

let printfct get_digest file =
	let digest = get_digest file in
	printf "%s  %s\n" digest file

let checkfct get_digest file =
	let chan = open_in file in

	let nb = ref 0 and failed = ref 0 in
	begin try while true
	do
		let line = input_line chan in
		Scanf.sscanf line "%s %s" (fun hex file ->
			let digest = get_digest file in
			let fail = digest <> hex in
			if fail then
				incr failed;
			incr nb;
			printf "%s: %s\n" file
			       (if fail then "FAILED" else "OK")
		)
	done
	with End_of_file -> () end;
	if !failed > 0 then
		eprintf "sha1sum: WARNING: %d of %d computed checksums did NOT match\n"
		        !failed !nb;
	close_in chan

(* main fct *)
let _ =
	let files = ref [] in
	let eoa = ref false and check = ref false in

	(* parse arg *)
	for i = 1 to Array.length Sys.argv - 1
	do
		let opt = Sys.argv.(i) in
		if !eoa then
			files := opt :: !files
		else
			match opt with
			| "--check" | "-c"  -> check := true
			| "--binary" | "-b" -> ()
			| "--text" | "-t"   -> ()
			| "--"              -> eoa := true
			| ""                -> ()
			| s                 ->
				if s.[0] = '-' then
					eprintf "unknown option: %s" s
				else
					files := opt :: !files
	done;

	let sha1 file = Sha1.to_hex (Sha1.file file) in
	let sha256 file = Sha256.to_hex (Sha256.file file) in

	let sha = match Filename.basename Sys.argv.(0) with
		| "sha256sum" -> sha256
		| "sha1sum"   -> sha1
		| _           -> sha1 in

	(* apply function of every file *)
	List.iter (fun file -> (if !check then checkfct else printfct) sha file)
	          (List.rev !files)
