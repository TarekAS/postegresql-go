.PHONY: build
build:
	docker build -t tarek/goapp:latest .

.PHONY: run
run:
	docker run goapp:latest

.PHONY: migrate
migrate:
	docker-compose exec fms python manage.py migrate

.PHONY: clean
clean:
	docker-compose down
