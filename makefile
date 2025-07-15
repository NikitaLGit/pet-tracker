build:
	docker compose build
	docker builder prune -f
	docker compose up -d