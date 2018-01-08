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
 *)

(** SHA OCaml bindings *)

(** buffer type *)
type buf = (char, Bigarray.int8_unsigned_elt, Bigarray.c_layout) Bigarray.Array1.t

(** Functor building a complete Digest implementation from Stub functions. *)
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

    (** Sha1.unsafe_update_substring ctx s ofs len updates the context
        with the substring of s starting at character number ofs and
        containing len characters. Unsafe: No range checking! *)
    val unsafe_update_substring: ctx -> string -> int -> int -> unit

    (** Sha1.update_buffer ctx a updates the context with a.
        Runs parallel to other threads if any exist. *)
    val update_buffer: ctx -> buf -> unit

    val update_fd: ctx -> Unix.file_descr -> int -> int

    val file_fast : string -> t

    (** Finalize the context and return digest *)
    val finalize: ctx -> t
  end

module type S =
  sig
    include Stubs

    (** The zero digest *)
    val zero : t

    (** Sha1.update_substring ctx s ofs len updates the context with the
        substring of s starting at character number ofs and containing len
        characters. *)
    val update_substring: ctx -> string -> int -> int -> unit

    (** Sha1.update_string ctx s updates the context with s. *)
    val update_string: ctx -> string -> unit

    (** Return an copy of the context *)
    val copy: ctx -> ctx

    (** Return the digest of the given string. *)
    val string : string -> t

    (** Sha1.substring s ofs len returns the digest of the substring of s starting
        at character number ofs and containing len characters. *)
    val substring : string -> int -> int -> t

    (** Return the digest of the given buffer. *)
    val buffer : buf -> t

    (** If len is nonnegative, Sha1.channel ic len reads len characters from
        channel ic and returns their digest, or raises End_of_file if end-of-file is
        reached before len characters are read. If len is negative, Sha1.channel ic
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


module Make (Stubs : Stubs) : S with type t = Stubs.t
