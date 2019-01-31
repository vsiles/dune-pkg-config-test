module C = Configurator.V1
module P = C.Pkg_config

let value opt ~default = match opt with
  | None -> default
  | Some x -> x

let query_pkg (c : C.t) (name : string) : P.package_conf =
  let default : P.package_conf =
    { P.libs  =  [ "-l" ^ name ]
    ; P.cflags = []
    }
  in
  match P.get c with
  | None -> default
  | Some pc ->
    value (P.query pc ~package:("lib" ^ name)) ~default
    (* TODO die instead of default here? *)

let concat_confs
  (c1 : P.package_conf)
  (c2 : P.package_conf)
  : P.package_conf =
  P.({ libs =   c1.libs @ c2.libs
  ; cflags = c1.cflags @ c2.cflags
  })

let () =
  let _ = match Sys.getenv "PKG_CONFIG_PATH" with
    | s -> Printf.printf "PKG_CONFIG_PATH=%s\n" s
    | exception Not_found -> print_endline "Can't find PKG_CONFIG_PATH in env"
  in
  C.main ~name:"heap" (fun (c : C.t) ->
    let a_conf : P.package_conf = query_pkg c "a" in
    let b_conf : P.package_conf = query_pkg c "b" in
    let conf = concat_confs a_conf b_conf in

    List.iter print_endline conf.P.cflags;
    List.iter print_endline conf.P.libs)
