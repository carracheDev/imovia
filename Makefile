.PHONY: infra-up infra-down api mobile admin api-test api-build mobile-test mobile-analyze admin-build admin-lint db-generate

infra-up:
	docker compose up -d postgres mailpit object-storage

infra-down:
	docker compose down

api:
	cd apps/api && npm run start:dev

mobile:
	cd apps/mobile && flutter run

admin:
	cd apps/admin && npm run dev -- --port 3001

api-test:
	cd apps/api && npm test

api-build:
	cd apps/api && npm run build

mobile-test:
	cd apps/mobile && flutter test

mobile-analyze:
	cd apps/mobile && flutter analyze

admin-build:
	cd apps/admin && npm run build

admin-lint:
	cd apps/admin && npm run lint

db-generate:
	cd apps/api && npx prisma generate
