include Hash.Make (struct
    type ctx
    type t = string
    let digest_length = 256

    external to_bin: t -> string = "%identity"
    external init: unit -> ctx = "stub_sha256_init"
    external unsafe_update_substring: ctx -> string -> int -> int -> unit = "stub_sha256_update"
    external update_buffer: ctx -> Hash.buf -> unit = "stub_sha256_update_bigarray"
    external finalize: ctx -> t = "stub_sha256_finalize"
  end)
