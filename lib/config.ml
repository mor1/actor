(** [ Config module ]
  contains all the configurations of the framework.
*)

(** Manager's address, all workders connect to this address *)
let manager_addr = "tcp://127.0.0.1:5555"
(** Manager's identifier *)
let manager_id = "manager_0"

(** File system path, Irmin or HDFS *)
let dfs_path = "storage.data"

(** Log configs: path, level, color, etc. *)
let level = Logger.DEBUG
let logdir = "log/"
let _ =  Logger.update_config level logdir ""

(** Max queue length of ZMQ send and receive *)
let high_warter_mark = 10_000

(** WebHDFS base addr and port *)
let webhdfs_addr = "192.168.99.100:50070"
