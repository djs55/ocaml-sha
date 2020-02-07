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
 (depends (dune (>= 2.0)) (ounit :with-test)))

(generate_opam_files true)
