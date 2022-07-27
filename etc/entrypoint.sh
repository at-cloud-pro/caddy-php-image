until nc -z mariadb 3306; do
    echo "Waiting for database"
    sleep 1
done

./bin/console doctrine:migrations:migrate --no-interaction

php-fpm --daemonize && caddy run --config=/etc/caddy/Caddyfile