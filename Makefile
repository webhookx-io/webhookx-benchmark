.PHONY: docker-up docker-down webhookx-setup restart bench-all

docker-up:
	@docker compose up -d

docker-down:
	@docker compose down -v

webhookx-setup:
	@docker exec webhookx webhookx admin sync config/webhookx.yml

restart: docker-down docker-up wait-for-ready webhookx-setup
	@sleep 1
	@echo "Environment started"

bench-all: bench-upstream bench-ingest-event bench-ingest-event-sync bench-egest bench-egest-slow-endpoint bench-egest-fail bench-e2e

bench-upstream: restart
	@echo "--- Running Upstream Benchmark ---"
	@docker compose run -q --rm k6 run -e URL=http://upstream:9999 $(ARGS) /scripts/upstream.js

bench-ingest-event: restart
	@echo "--- Running Ingest Event Benchmark ---"
	@docker compose run -q --rm k6 run -e URL=http://webhookx:9600 $(ARGS) /scripts/ingest-event.js

bench-ingest-event-sync: restart
	@echo "--- Running Ingest Event Sync Benchmark ---"
	@docker compose run -q --rm k6 run -e URL=http://webhookx:9600 $(ARGS) /scripts/ingest-event-sync.js

bench-egest: restart
	@echo "--- Running Egest Benchmark ---"
	@docker compose run -q --rm k6 run -e URL=http://webhookx:9600 /scripts/egest.js

bench-egest-slow-endpoint: restart
	@echo "--- Running Egest (with 100ms delay endpoint) Benchmark ---"
	@docker compose run -q --rm k6 run -e URL=http://webhookx:9600 /scripts/egest-slow-endpoint.js

bench-egest-fail: restart
	@echo "--- Running Failing Upstream (Retry) Benchmark ---"
	@docker compose run -q --rm k6 run -e URL=http://webhookx:9600 $(ARGS) /scripts/egest-fail.js

bench-e2e: bench-e2e-1000 bench-e2e-5000 bench-e2e-10000

bench-e2e-1000: restart
	@echo "--- Running E2E Latency 1000 RPS Benchmark ---"
	@docker compose run -q --rm k6 run -e URL=http://webhookx:9600 -e RPS=1000 $(ARGS) /scripts/e2e-fixed-rps.js
	@curl http://localhost:9999/latency_state

bench-e2e-5000: restart
	@echo "--- Running E2E Latency 5000 RPS Benchmark ---"
	@docker compose run -q --rm k6 run -e URL=http://webhookx:9600 -e RPS=5000 $(ARGS) /scripts/e2e-fixed-rps.js
	@curl http://localhost:9999/latency_state

bench-e2e-10000: restart
	@echo "--- Running E2E Latency 10000 RPS Benchmark ---"
	@docker compose run -q --rm k6 run -e URL=http://webhookx:9600 -e RPS=10000 $(ARGS) /scripts/e2e-fixed-rps.js
	@curl http://localhost:9999/latency_state

wait-for-ready:
	@docker run --rm --network webhookx-benchmark_default jwilder/dockerize -wait tcp://webhookx:9600 -timeout 10s
