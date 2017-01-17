include Hash.Make (struct
    type ctx
    type t = string
    let digest_length = 512

    external to_bin: t -> string = "%identity"
    external init: unit -> ctx = "stub_sha512_init"
    external unsafe_update_substring: ctx -> string -> int -> int -> unit = "stub_sha512_update"
    external update_buffer: ctx -> Hash.buf -> unit = "stub_sha512_update_bigarray"
    external finalize: ctx -> t = "stub_sha512_finalize"
  end)
