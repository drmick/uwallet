# Решение первого тестового задания
## Запуск через docker-compose

```
docker-compose run cli
```

```
# Сгенерировать ключ
docker-compose run cli generate

# Посмотреть баланс
docker-compose run cli balance

# Посмотреть посмотреть текущий адрес
docker-compose run cli addr

# Отправить перевод
docker-compose run cli send ADDRESS VALUE
# Пример docker-compose run cli send mfXYf6sLQZXUrJrXWhVrywB8SQJB84k1Et 0.00000123

# Список команд 
docker-compose run cli help
```
Примечание: Ключ в файле base58key.txt уже сгенерирован, в кошельке есть небольшая сумма. Можно либо  его удалить и сгенерировтаь новый или тестировать на нем

При удачном переводе должно прийти сообщение вида:
```
Success!
Transaction ID: a8a1c11dd7f5f3bb179628a8093e5e0cf859a88edfe4884710f7b5330aa02abe
Sent amount: 0.00000000 tBTC
Cashback: 0.00103231 tBTC
Fee: 0.00000374 tBTC
```

## Запуск напрямую

```
bundle install
```
```
# Сгенерировать ключ
ruby cli.rb generate

# Посмотреть баланс
ruby cli.rb balance

# Посмотреть посмотреть текущий адрес
ruby cli.rb addr

# Отправить перевод
ruby cli.rb send ADDRESS VALUE
# Пример ruby cli.rb send mfXYf6sLQZXUrJrXWhVrywB8SQJB84k1Et 0.00000123

# Список команд
ruby cli.rb help
```

Проверял на Ubuntu 20.04.3 LTS