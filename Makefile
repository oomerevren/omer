# Otonom Medya Holdingi - Master Makefile (v2.5)

.PHONY: up down restart logs ps backup test-integration test-dr clean

up:
	docker compose up -d

down:
	docker compose down

restart:
	docker compose restart

logs:
	docker compose logs -f

ps:
	docker compose ps

backup:
	./scripts/backup.sh

test-integration:
	./tests/integration_test.sh

test-e2e:
	./tests/e2e/test_full_flow.sh

shell-db:
	docker exec -it medya-postgres psql -U ${POSTGRES_USER} -d ${POSTGRES_DB}

clean:
	docker compose down -v
	rm -rf backups/*
	rm -rf ozel/storage/processed_assets/*
