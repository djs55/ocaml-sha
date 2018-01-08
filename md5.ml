include Hash.Make (struct
    type ctx
    type t = string
    let digest_length = 128

    external to_bin: t -> string = "%identity"
    external init: unit -> ctx = "stub_md5_init"
    external unsafe_update_substring: ctx -> string -> int -> int -> unit = "stub_md5_update"
    external update_buffer: ctx -> Hash.buf -> unit = "stub_md5_update_bigarray"
    external update_fd: ctx -> Unix.file_descr -> int -> int = "stub_md5_update_fd"
    external file_fast: string -> t = "stub_md5_file"
    external finalize: ctx -> t = "stub_md5_finalize"
  end)
