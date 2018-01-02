(*
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

let ex_strings_sha512 = [
	("",
	"cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e");
	("The quick brown fox jumps over the lazy cog",
	"3eeee1d0e11733ef152a6c29503b3ae20c4f1f3cda4cb26f1bc1a41f91c7fe4ab3bd86494049e201c4bd5155f31ecb7a3c8606843c4cc8dfcab7da11c8ae5045");
	("The quick brown fox jumps over the lazy dog",
	"07e547d9586f6a73f73fbac0435ed76951218fb7d0c8d788a309d785436bbb642e93a252a954f23912547d1e8a3b5ed6e1bfd7097821233fa0538f3db854fee6"); ]


let ex_files_sha1 =
	[ ("README",
	"3dd0bb5bd5614a8e2dd9b03806dc4edd5ec10905") ]

let ex_files_sha256 =
	[ ("README",
	"faad0b6f78c304d861a6f0f46306f8921c5f385b8a47267a59afad3e783b2ebf") ]

let ex_files_sha512 =
	[ ("README",
	"6dab66983e0b37a5eeb83900434ea8fe70fc1319653cbb2483c297563663de58f9d5c94e452463d8decf9039ad94b2c924e7af36841589a565979cc06ed94624") ]

let ex_channels_sha1 =
	[ ("shatest.ml", "e13052afa4916d56994378f847f157596f9638a2") ]

let ex_channels_sha256 =
	[ ("shatest.ml",
	"51598a80bbec8fdcb32c3d180c3e806bf09eb0f5b5bb6f51031a78f46c83caef") ]

let ex_channels_sha512 =
	[ ("shatest.ml",
	"2f8e603774643ce152620e1dd94601393e78d33a3e6f67b86df2ef87eb4ad0cde72b481208eaa0249bbcf64072f2fb03b06abd006c5213c7546936ae9e9a1dc1") ]

let stringfct_sha1 s = Sha1.to_hex (Sha1.string s)
let stringfct_sha256 s = Sha256.to_hex (Sha256.string s)
let stringfct_sha512 s = Sha512.to_hex (Sha512.string s)

let filefct_sha1 s = Sha1.to_hex (Sha1.file s)
let filefct_sha256 s = Sha256.to_hex (Sha256.file s)
let filefct_sha512 s = Sha512.to_hex (Sha512.file s)

let channelfct_sha1 s i = Sha1.to_hex (Sha1.channel s i)
let channelfct_sha256 s i = Sha256.to_hex (Sha256.channel s i)
let channelfct_sha512 s i = Sha512.to_hex (Sha512.channel s i)

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
	  "SHA512 example strings" >::
		test_strings stringfct_sha512 ex_strings_sha512;
	  "SHA512 reading a file" >::
		test_file filefct_sha512 ex_files_sha512;
	  "SHA512 reading few byte from channel" >::
		test_channel channelfct_sha512 ex_channels_sha512;
	]

let _ = run_test_tt ~verbose:true suite
