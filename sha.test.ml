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
 * SHA1 OCaml binding test unit
 *)

open OUnit

let alls = [
	("", "da39a3ee5e6b4b0d3255bfef95601890afd80709");
	("The quick brown fox jumps over the lazy cog", "de9f2c7fd25e1b3afad3e85a0bd17d9b100db4b3");
	("The quick brown fox jumps over the lazy dog", "2fd4e1c67a2d28fced849ee1bb76e7391b93eb12");
	]

let test_strings _ =
	let rec test_string l = match l with
		| [] -> ()
		| (s,r) :: l ->
			let digest = Sha1.string s in
			assert_equal r (Sha1.to_hex digest);
			test_string l in
	test_string alls

let test_file _ =
	let v = "8da1775cea8540cf22a32765eadcb2239cc4d392" in
	let digest = Sha1.file "README" in
	assert_equal v (Sha1.to_hex digest)

let test_channel _ =
	let v = "e13052afa4916d56994378f847f157596f9638a2" in
	let chan = open_in_bin "sha.test.ml" in
	let digest = Sha1.channel chan 20 in
	close_in chan;
	assert_equal v (Sha1.to_hex digest)

let suite = "SHA1 binding test" >:::
	[ "example strings" >:: test_strings;
	  "reading a file" >:: test_file;
	  "reading few byte from channel" >:: test_channel;
	]

let _ = run_test_tt ~verbose:true suite
