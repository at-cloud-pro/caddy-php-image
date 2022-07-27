until nc -z mariadb 3306; do
    echo "Waiting for database"
    sleep 1
done

php-fpm --daemonize && caddy run --config=/etc/caddy/Caddyfile