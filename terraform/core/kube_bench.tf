resource "kubernetes_cron_job_v1" "kube_bench" {
  metadata {
    name      = "kube-bench-scan"
    namespace = "security"
  }

  spec {
    schedule                      = "0 */2 * * *"
    successful_jobs_history_limit = 3
    failed_jobs_history_limit     = 1

    job_template {
      metadata {
        labels = {
          app = "kube-bench"
        }
      }

      spec {
        template {
          metadata {
            labels = {
              app = "kube-bench"
            }
          }

          spec {
            host_pid = true

            container {
              name    = "kube-bench"
              image   = "aquasec/kube-bench:v0.8.0"
              command = ["/bin/sh", "-c"]
              args = [
                <<-EOT
                # Chạy kube-bench
                kube-bench --benchmark aks-1.0 > /results/output.txt 2>&1
                
                # Tạo JSON output riêng
                kube-bench --benchmark aks-1.0 --json > /results/output.json 2>&1
                EOT
              ]

              volume_mount {
                name       = "results"
                mount_path = "/results"
              }
              volume_mount {
                name       = "var-lib-kubelet"
                mount_path = "/var/lib/kubelet"
                read_only  = true
              }
              volume_mount {
                name       = "etc-kubernetes"
                mount_path = "/etc/kubernetes"
                read_only  = true
              }
            }

            container {
              name    = "slack-alert"
              image   = "alpine:3.18"
              command = ["/bin/sh", "-c"]
              args = [
                <<-EOT
                # Install tools
                apk add --no-cache curl jq
                
                # Chờ kube-bench chạy xong
                echo "Waiting for kube-bench to complete..."
                sleep 90
                
                # Đọc kết quả
                OUTPUT_FILE="/results/output.txt"
                JSON_FILE="/results/output.json"
                
                if [ ! -f "$OUTPUT_FILE" ]; then
                  echo "Output file not found!"
                  exit 1
                fi
                
                # Parse summary
                TOTAL_PASS=$(grep -oP '\d+(?= checks PASS)' $OUTPUT_FILE || echo "0")
                TOTAL_FAIL=$(grep -oP '\d+(?= checks FAIL)' $OUTPUT_FILE || echo "0")
                TOTAL_WARN=$(grep -oP '\d+(?= checks WARN)' $OUTPUT_FILE || echo "0")
                
                # Lấy danh sách FAIL
                FAIL_LIST=$(grep "\[FAIL\]" $OUTPUT_FILE | head -20 || echo "None")
                
                # Lấy danh sách WARN
                WARN_LIST=$(grep "\[WARN\]" $OUTPUT_FILE | head -10 || echo "None")
                
                # Tạo message
                MESSAGE="*🔍 CIS AKS Benchmark Report*\n"
                MESSAGE="$MESSAGE*Cluster:* ${CLUSTER_NAME}\n"
                MESSAGE="$MESSAGE*Time:* $(date -u '+%Y-%m-%d %H:%M:%S UTC')\n\n"
                MESSAGE="$MESSAGE*📊 Summary:*\n"
                MESSAGE="$MESSAGE✅ Pass: $TOTAL_PASS\n"
                MESSAGE="$MESSAGE❌ Fail: $TOTAL_FAIL\n"
                MESSAGE="$MESSAGE⚠️ Warn: $TOTAL_WARN\n\n"
                
                if [ "$TOTAL_FAIL" -gt 0 ]; then
                  MESSAGE="$MESSAGE*❌ Failed Controls:*\n\`\`\`\n$FAIL_LIST\n\`\`\`\n\n"
                fi
                
                if [ "$TOTAL_WARN" -gt 0 ]; then
                  MESSAGE="$MESSAGE*⚠️ Warning Controls:*\n\`\`\`\n$WARN_LIST\n\`\`\`"
                fi
                
                # Gửi Slack
                curl -X POST "${SLACK_WEBHOOK_URL}" \
                  -H 'Content-type: application/json' \
                  -d "{\"text\": \"$MESSAGE\"}"
                
                echo "Alert sent to Slack!"
                EOT
              ]

              env {
                name  = "SLACK_WEBHOOK_URL"
                value = var.slack_webhook_url
              }
              env {
                name  = "CLUSTER_NAME"
                value = azurerm_kubernetes_cluster.aks.name
              }

              volume_mount {
                name       = "results"
                mount_path = "/results"
              }
            }

            volume {
              name = "results"
              empty_dir {}
            }
            volume {
              name = "var-lib-kubelet"
              host_path {
                path = "/var/lib/kubelet"
              }
            }
            volume {
              name = "etc-kubernetes"
              host_path {
                path = "/etc/kubernetes"
              }
            }

            restart_policy = "Never"
          }
        }
      }
    }
  }

  depends_on = [kubernetes_namespace.security]
}

# Variables
