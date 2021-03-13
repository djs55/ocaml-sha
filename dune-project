(lang dune 2.0)

(name sha)

(source (github djs55/ocaml-sha))

(license ISC)

(authors "Vincent Hanquez"
         "Thomas Gazagnaire"
         "Goswin von Brederlow"
         "Eric Cooper"
         "Florent Monnier"
         "Forrest L Norvell"
         "Vincent Bernadoff"
         "David Scott")

(maintainers dave@recoil.org)

(package
 (name sha)
 (synopsis "Binding to the SHA cryptographic functions")
 (description "This is the binding for SHA interface code in OCaml. Offering the same
interface than the MD5 digest included in the OCaml standard library.
It's currently providing SHA1, SHA256 and SHA512 hash functions.")
 (depends (dune (>= 2.0)) (ounit :with-test)))

(generate_opam_files true)
