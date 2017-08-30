#!/bin/bash

read -r -d '' help <<HELP
💖                  💞
💘 Swiss Army Waifu 💓
💝                  💕

*** 💁 Available Commands ->

install
  dep ensures, generates, then builds the project.

env [set|unset|dot] [path]
  set relevant environment variables
  * use like \`eval \$(./tool env)\`
  * ex: eval \$(./tool env)
  * ex: eval \$(./tool env unset)
  * for dot, if path isn't set, i write to stdout.

ui service
  try to open a service's web ui
  * usable for: crdb1, dgraph
  * ex: ./tool ui dgraph

help
  this message
HELP

OPEN="$(uname | grep -q Linux && echo "xdg-")open"

cmd_install() {
    echo "🚚 updating dependencies"
    dep ensure # currently a bad idea.

    echo "⚙️ running generate tasks"
    go generate ./...

    echo "💫 installing"
    go install ./...
}

cmd_env_set() {
    SET=export
    SPLIT="="

    if [[ "$SHELL" == *fish* ]]; then
        SET="set -gx"
        SPLIT=" "
    fi

    echo "$SET NATS_ADDR$SPLIT$(docker-compose port nats 4222);"
    echo "$SET DGRAPH_ADDR$SPLIT$(docker-compose port dgraph 9080);"
    echo "$SET CRDB_ADDR$SPLIT$(docker-compose port crdb1 26257);"
    
    (>&2 echo "✅ Environment set.")    
}

cmd_env_dot() {
    echo "NATS_ADDR=$(docker-compose port nats 4222)" > $1
    echo "DGRAPH_ADDR=$(docker-compose port dgraph 9080)" >> $1
    echo "CRDB_ADDR=$(docker-compose port crdb1 26257)" >> $1
    
    (>&2 echo "📝  .env file written")    
}

cmd_env_unset() {
    SET=export
    SPLIT="="

    if [[ "$SHELL" == *fish* ]]; then
        SET="set -e"
        SPLIT=" "
    fi

    echo "$SET NATS_ADDR;"
    echo "$SET DGRAPH_ADDR;"
    echo "$SET CRDB_ADDR;"

    (>&2 echo "❌ Environment cleared.")
}

cmd_ui() {
    url="http://$(docker-compose port $1 8080)"
    echo "🛠 trying to open $url"
    $OPEN $url
}

main() {
    case "$1" in
        help) echo "$help";;
        env) cmd_env_${2:-set} "${3:-/dev/stdout}";;
        ui) cmd_ui $2;;
        install) cmd_install;;
        *) echo "$help";;
    esac
}

main "$@"
