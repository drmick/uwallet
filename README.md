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

# Посмотреть текущий адрес
docker-compose run cli addr

# Отправить перевод
docker-compose run cli send ADDRESS VALUE
# Пример docker-compose run cli send tb1qldpy0a97npgh2vayq8pzeyvt5c9sv8zryz253g 0.00001

# Список команд 
docker-compose run cli help
```
Примечание: Ключ в файле base58key.txt уже сгенерирован, в кошельке есть небольшая сумма. Можно либо  его удалить и сгенерировтаь новый или тестировать на нем

При удачном переводе должно прийти сообщение вида:
```
Success!
Transaction ID: 6e96f808ab35630063fb039e00d508c669d71e18d1b2594c5006850ac23d1b34
Sent amount: 0.00001000 tBTC
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

# Посмотреть текущий адрес
ruby cli.rb addr

# Отправить перевод
ruby cli.rb send ADDRESS VALUE
# Пример ruby cli.rb send tb1qldpy0a97npgh2vayq8pzeyvt5c9sv8zryz253g 0.00001

# Список команд
ruby cli.rb help
```

Проверял на Ubuntu 20.04.3 LTS

Если слишком быстро отправлять переводы, то API иногда может присылать сообщения, что данных по транзакциям нет (или другие ошибки). Скорее данные туда не успевают попадать
Иногда случается, что на одни и те же запросы приходят 404, 200, 404 поочередно