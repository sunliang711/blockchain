job "bitcoin-node" {
  datacenters = ["aws-main"]
  type        = "service"

  affinity {
    attribute = "${meta.worker}"
    value     = "1"
    weight    = 100
  }

  constraint {
    attribute = "${meta.ingress}"
    operator  = "!="
    value     = "1"
  }

  group "bitcoin-node" {
    count = 1

    spread {
      attribute = "${unique.hostname}"
      weight    = 100
    }
    ephemeral_disk {
      migrate = false
      size    = 50
      sticky  = false
    }
    network {
      port "btc-p2p" { to = 8333 }
      port "btc-rpc" { to = 8332 }
    }
    // update {
    //   max_parallel      = 1
    //   health_check      = "checks"
    //   min_healthy_time  = "10s"
    //   healthy_deadline  = "2m"
    //   progress_deadline = "10m"
    //   auto_revert       = true
    //   auto_promote      = true
    //   canary            = 1
    //   stagger           = "15s"
    // }
    scaling {
      enabled = true
      min     = 1
      max     = 10
    }

    volume "bitcoin_data" {
      type      = "host"
      read_only = false
      source    = "bitcoin_data"
    }

    restart {
      attempts = 10
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }


    task "bitcoin-node" {
      logs {
        max_files     = 4
        max_file_size = 10
      }

      driver = "docker"

      config {
        image = "127.0.0.1/btc-node-master:v3"
        ports = ["btc-p2p", "btc-rpc"]
      }
      volume_mount {
        volume      = "bitcoin_data"
        destination = "/root/datadir"
        read_only   = false
      }

      env = {
        "network" = "main"
      }
      resources {
        cpu        = 100 # MHz， no worry, keep it as low as possible.
        memory     = 50  # MB, keep it as your common memory usage or do not change.
        memory_max = 2024 # MB, keep it as your max memory usage。Exceeding this value will trigger OutOfMemory kill.
      }

      service {
        name = "bitcoin-node"
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.btcnode-all.entrypoints=http",
          "traefik.http.routers.btcnode-all.rule=Host(`btcnode.all.internal.traefik`)"
        ]
        port = "btc-rpc"

        check {
          type     = "tcp"
          interval = "10s"
          timeout  = "5s"

          check_restart {
            limit           = 5
            grace           = "10s"
            ignore_warnings = false
          }
        }
      }

    }

  }
}