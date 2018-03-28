

consul_id=$(docker run -P -d --rm consul:0.9.3)
consul_port=$(docker inspect --format '{{ (index (index .NetworkSettings.Ports "8500/tcp") 0).HostPort }}' $consul_id)

export CONSUL_HTTP_ADDR="localhost:$consul_port"

#if ! which basht >/dev/null 2>&1; then
#  echo "Error, to run tests 'basht' is required"
#  exit 1
#fi

docker run basht tests/lib.consul.sh

docker kill $consul_id
