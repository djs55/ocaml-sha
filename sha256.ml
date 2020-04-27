include Hash.Make (struct
    type ctx
    type t = string
    let digest_length = 256

    external to_bin: t -> string = "%identity"
    external init: unit -> ctx = "stub_sha256_init"
    external unsafe_update_substring: ctx -> string -> int -> int -> unit = "stub_sha256_update"
    external unsafe_update_bigstring: ctx -> Hash.buf -> int -> int -> unit = "stub_sha256_update_bigarray"
    external update_fd: ctx -> Unix.file_descr -> int -> int = "stub_sha256_update_fd"
    external file_fast: string -> t = "stub_sha256_file"
    external finalize: ctx -> t = "stub_sha256_finalize"
  end)
