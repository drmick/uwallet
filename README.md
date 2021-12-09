## Run via docker-compose

```
docker-compose build
```

```
# Generate key
docker-compose run uwallet generate

# Show balance
docker-compose run uwallet balance

# Show current waller
docker-compose run uwallet addr

# Send money
docker-compose run uwallet send ADDRESS VALUE
# Example: docker-compose run uwallet send tb1qldpy0a97npgh2vayq8pzeyvt5c9sv8zryz253g 0.00001

# Show help
docker-compose run uwallet help
```
Note: The key in the base58key.txt file has already been generated, there is a small amount in the wallet. You can either delete it and generate a new one or test on it

If the translation is successful, you should receive a message of the form:
```
Success!
Transaction ID: 6e96f808ab35630063fb039e00d508c669d71e18d1b2594c5006850ac23d1b34
Sent amount: 0.00001000 BTC
Cashback: 0.00103231 BTC
Fee: 0.00000374 BTC
```

## Run directly

```
bundle install
```
```
# Generate key
ruby bin/uwallet.rb generate

# Show balance
ruby bin/uwallet.rb balance

# Show current wallet
ruby bin/uwallet.rb addr

# Send money
ruby bin/uwallet.rb send ADDRESS VALUE
# Example: ruby bin/uwallet.rb send tb1qldpy0a97npgh2vayq8pzeyvt5c9sv8zryz253g 0.00001

# Help__
ruby bin/uwallet.rb help
```
