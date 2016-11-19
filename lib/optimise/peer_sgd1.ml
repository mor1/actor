(** [ Distributed Stochastic Gradient Decendent ] *)

open Owl
module MX = Dense.Real
module P2P = Peer

(* variables used in distributed sgd *)
let data_x = ref (MX.empty 0 0)
let data_y = ref (MX.empty 0 0)
let _model = ref (MX.empty 0 0)
let gradfn = ref Owl_optimise.square_grad
let lossfn = ref Owl_optimise.square_loss
let step_t = ref 0.001

(* prepare data, model, gradient, loss *)
let init x y m g l =
  data_x := x;
  data_y := y;
  _model := m;
  gradfn := g;
  lossfn := l;
  MX.iteri_cols (fun i v -> P2P.set i v) !_model

let calculate_gradient b x y m g l =
  let xt, i = MX.draw_rows x b in
  let yt = MX.rows y i in
  let yt' = MX.(xt $@ m) in
  let d = g xt yt yt' in
  Logger.info "loss = %.10f" (l yt yt' |> MX.sum);
  d

let update_local_model = None

let schedule id =
  Logger.debug "%s: scheduling ..." id;
  let n = MX.col_num !_model in
  let k = Stats.Rnd.uniform_int ~a:0 ~b:(n - 1) () in
  [ k ]

let push id params =
  List.map (fun (k,v) ->
    Logger.debug "%s: working on %i ..." id k;
    let y = MX.col !data_y k in
    let d = calculate_gradient 10 !data_x y v !gradfn !lossfn in
    let d = MX.(d *$ !step_t) in
    (k, d)
  ) params

let barrier wait_bar context updates = Barrier.p2p_bsp wait_bar context updates

let pull updates =
  Logger.debug "pulling %i updates ..." (List.length updates);
  List.map (fun (k,v,t) ->
    let v0, _ = P2P.get k in
    let v1 = MX.(v0 -@ v) in
    k, v1, t
  ) updates

let stop () = false

let start jid =
  (* register schedule, push, pull functions *)
  P2P.register_barrier barrier;
  P2P.register_pull pull;
  P2P.register_schedule schedule;
  P2P.register_push push;
  (* start running the ps *)
  Logger.info "P2P: sdg algorithm starts running ...";
  P2P.start jid Config.manager_addr
