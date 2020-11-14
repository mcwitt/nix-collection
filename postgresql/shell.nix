{ pkgs ? import <nixpkgs> { }, ... }:
pkgs.mkShell {
  name = "postgres-playground";
  buildInputs = with pkgs; [ postgresql ];
  shellHook = ''
    export PGDATA="$PWD/postgres_data"
    export PGHOST="$PWD/postgres"
    export LOG_PATH="$PWD/postgres/LOG"
    export PGDATABASE="postgres"
    export DATABASE_URL="postgresql:///postgres?host=$PGHOST"
    if [ ! -d "$PGHOST" ]; then
      mkdir -p "$PGHOST"
    fi
    if [ ! -d "$PGDATA" ]; then
      echo 'Initializing postgresql database...'
      ${pkgs.postgresql}/bin/initdb "$PGDATA" --auth=trust > /dev/null
    fi
    ${pkgs.postgresql}/bin/pg_ctl start -l "$LOG_PATH" -o "-c listen_addresses=localhost -c unix_socket_directories=$PGHOST"
    trap "${pkgs.postgresql}/bin/pg_ctl stop" EXIT
  '';

}
