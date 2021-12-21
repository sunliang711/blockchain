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
      port "btc-p2p" { to = 8890 }
      port "btc-rpc" { to = 8338 }
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

    volume "bitcoin-node" {
      type            = "csi"
      read_only       = false
      source          = "bitcoin-node_efs"
      attachment_mode = "file-system"
      access_mode     = "multi-node-multi-writer"
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
        image = "127.0.0.1/btc-node-master:v1"
        ports = ["btc"]
      }
      volume_mount {
        volume      = "bitcoin-node"
        destination = "/root/datadir"
        read_only   = false
      }

      env = {
        "network"    = "main"
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