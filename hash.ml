(*
 *	Copyright (C) 2017 Christopher Zimmermann <christopher@gmerlin.de>
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
 * SHA OCaml binding
 *)

type buf = (char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t

let blksize = 4096

module type Stubs =
sig
  (** context type - opaque *)
  type ctx

  (** digest type - opaque *)
  type t

  (** return a binary representation of the given digest *)
  val to_bin : t -> string

  (** length of digest in bits *)
  val digest_length: int

  (** Create a new context *)
  val init: unit -> ctx

  (** unsafe_update_substring ctx s ofs len updates the context
      with the substring of s starting at character number ofs and
      containing len characters. Unsafe: No range checking! *)
  val unsafe_update_substring: ctx -> string -> int -> int -> unit

  val unsafe_update_bigstring: ctx -> buf -> int -> int -> unit

  val update_fd: ctx -> Unix.file_descr -> int -> int

  val file_fast: string -> t

  (** Finalize the context and return digest *)
  val finalize: ctx -> t
end

module type S =
sig
  include Stubs

  (** The zero digest *)
  val zero : t

  (** update_substring ctx s ofs len updates the context with the
      substring of s starting at character number ofs and containing len
      characters. *)
  val update_substring: ctx -> string -> int -> int -> unit

  (** update_string ctx s updates the context with s. *)
  val update_string: ctx -> string -> unit

  (** update_buffer ctx a updates the context with a.
      Runs parallel to other threads if any exist. *)
  val update_buffer: ctx -> buf -> unit

  (** Return an copy of the context *)
  val copy: ctx -> ctx

  (** Return the digest of the given string. *)
  val string : string -> t

  (** substring s ofs len returns the digest of the substring of s starting
      at character number ofs and containing len characters. *)
  val substring : string -> int -> int -> t

  (** Return the digest of the given buffer. *)
  val buffer : buf -> t

  (** If len is nonnegative, channel ic len reads len characters from
      channel ic and returns their digest, or raises End_of_file if end-of-file is
      reached before len characters are read. If len is negative, channel ic
      len reads all characters from ic until end-of-file is reached and return their
      digest. *)
  val channel : in_channel -> int -> t

  (** Return the digest of the file whose name is given. *)
  val file : string -> t

  (** Return the digest of the file whose name is given using fast C function *)
  val file_unbuffered : string -> t

  (** Write a digest on the given output channel. *)
  val output : out_channel -> t -> unit

  (** Read a digest from the given input channel. *)
  val input : in_channel -> t

  (** return a binary representation of the given digest *)
  val to_bin : t -> string

  (** return a printable hexadecimal representation of the given digest *)
  val to_hex : t -> string
end

module Make(Stubs: Stubs) :S with type t = Stubs.t =
struct
  include Stubs

  module Bigstring = Bigarray.Array1

  let update_substring ctx s ofs len =
    if len <= 0 || String.length s < ofs + len then
      invalid_arg "substring";
    unsafe_update_substring ctx s ofs len

  let update_string ctx s =
    unsafe_update_substring ctx s 0 (String.length s)

  let string s =
    let ctx = init () in
    unsafe_update_substring ctx s 0 (String.length s);
    finalize ctx

  let zero = string ""

  let copy :ctx -> ctx = fun x -> Obj.obj (Obj.dup (Obj.repr x))

  let substring s ofs len =
    let ctx = init () in
    update_substring ctx s ofs len;
    finalize ctx

  let update_bigstring ctx ?(pos=0) ?len buf =
    let len = match len with
      | None -> Bigstring.dim buf - pos
      | Some len -> len
    in
    if pos < 0 || len < 0 || pos + len >= Bigstring.dim buf
    then invalid_arg "Hash.update_bigstring";
    unsafe_update_bigstring ctx buf pos len

  let update_buffer ctx buf =
    unsafe_update_bigstring ctx buf 0 (Bigstring.dim buf)

  let buffer buf =
    let ctx = init () in
    update_buffer ctx buf;
    finalize ctx

  let channel chan len =
    let ctx = init ()
    and buf = Bytes.create blksize in

    let left = ref len and eof = ref false in
    while (!left == -1 || !left > 0) && not !eof
    do
      let len = if !left < 0 then blksize else (min !left blksize) in
      let readed = Pervasives.input chan buf 0 len in
      if readed = 0 then
        eof := true
      else begin
        unsafe_update_substring ctx (Bytes.unsafe_to_string buf) 0 readed;
        if !left <> -1 then left := !left - readed
      end
    done;
    if !left > 0 && !eof then raise End_of_file;
    finalize ctx

    let file name =
      let chan = open_in_bin name in
      let digest = channel chan (-1) in
      close_in chan;
      digest

    let file_unbuffered name =
      let fd = Unix.(openfile name [O_RDONLY; O_CLOEXEC] 0) in
      let ctx = init () in
      while update_fd ctx fd max_int > 0 do () done;
      Unix.close fd;
      finalize ctx

    let to_hex digest =
      let bin = to_bin digest in
      let hex = Bytes.create (String.length bin * 2) in
      assert (String.length bin * 8 = digest_length);
      let map = "0123456789abcdef" in
      for i = 0 to String.length bin - 1 do
        Bytes.set hex (2*i)   map.[int_of_char bin.[i] lsr 4];
        Bytes.set hex (2*i+1) map.[int_of_char bin.[i] land 0x0f];
      done;
      Bytes.unsafe_to_string hex

    let input chan =
      channel chan (-1)

    let output chan digest =
      output_string chan (to_hex digest)
  end
