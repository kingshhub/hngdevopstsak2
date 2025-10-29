# Decision notes 


 - Used docker-compose only (no k8s) per constraints.
 - Nginx `backup` upstream chosen to keep one server passive until failover.
 - Used `max_fails=1` + `fail_timeout=3s` so a single failing request marks the server down fast.
 - Set `proxy_next_upstream` to include `timeout` and `http_5xx` to satisfy "retry on timeout or 5xx" requirement.
 - Kept request timeouts < 10s (`proxy_read_timeout` and `proxy_send_timeout` set to 8s) to respect maximum request duration.
 - Templating is performed with a simple `envsubst` approach so CI/Grader can control `ACTIVE_POOL` with environment variables and still support `nginx -s reload`.