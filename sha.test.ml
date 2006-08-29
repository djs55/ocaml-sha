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
 * SHA1 & SHA256 OCaml binding test unit
 *)

open OUnit

let ex_strings_sha1 = [
	("",
	"da39a3ee5e6b4b0d3255bfef95601890afd80709");
	("The quick brown fox jumps over the lazy cog",
	"de9f2c7fd25e1b3afad3e85a0bd17d9b100db4b3");
	("The quick brown fox jumps over the lazy dog",
	"2fd4e1c67a2d28fced849ee1bb76e7391b93eb12"); ]

let ex_strings_sha256 = [
	("",
	"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855");
	("The quick brown fox jumps over the lazy cog",
	"e4c4d8f3bf76b692de791a173e05321150f7a345b46484fe427f6acc7ecc81be");
	("The quick brown fox jumps over the lazy dog",
	"d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"); ]

let ex_files_sha1 =
	[ ("README",
	"8da1775cea8540cf22a32765eadcb2239cc4d392") ]

let ex_files_sha256 =
	[ ("README",
	"4eea769a1a5c7be83342923a240d68bc8170f170f4b6265a044261e0f7a88af0") ]

let ex_channels_sha1 =
	[ ("sha.test.ml", "e13052afa4916d56994378f847f157596f9638a2") ]

let ex_channels_sha256 =
	[ ("sha.test.ml",
	"51598a80bbec8fdcb32c3d180c3e806bf09eb0f5b5bb6f51031a78f46c83caef") ]

let stringfct_sha1 s = Sha1.to_hex (Sha1.string s)
let stringfct_sha256 s = Sha256.to_hex (Sha256.string s)

let filefct_sha1 s = Sha1.to_hex (Sha1.file s)
let filefct_sha256 s = Sha256.to_hex (Sha256.file s)

let channelfct_sha1 s i = Sha1.to_hex (Sha1.channel s i)
let channelfct_sha256 s i = Sha256.to_hex (Sha256.channel s i)

let test_strings stringfct arr _ =
	List.iter (fun (s,r) -> assert_equal r (stringfct s)) arr

let test_file filefct arr _ =
	List.iter (fun (f,r) -> assert_equal r (filefct f)) arr

let test_channel channelfct arr _ =
	List.iter (fun (c,r) ->
		let chan = open_in_bin c in
		let digest = channelfct chan 20 in
		close_in chan;
		assert_equal r digest) arr

let suite = "SHA binding test" >:::
	[ "SHA1 example strings" >::
		test_strings stringfct_sha1 ex_strings_sha1;
	  "SHA1 reading a file" >::
		test_file filefct_sha1 ex_files_sha1;
	  "SHA1 reading few byte from channel" >::
		test_channel channelfct_sha1 ex_channels_sha1;
	  "SHA256 example strings" >::
		test_strings stringfct_sha256 ex_strings_sha256;
	  "SHA256 reading a file" >::
		test_file filefct_sha256 ex_files_sha256;
	  "SHA256 reading few byte from channel" >::
		test_channel channelfct_sha256 ex_channels_sha256;
	]

let _ = run_test_tt ~verbose:true suite
