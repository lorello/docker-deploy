# Library to access the consul API
# requires consul binary in PATH

consul::server()
{
  local readonly server=${CONSUL_HTTP_ADDR:-localhost}
  echo $server
}

# check if consul is available
consul::isup()
{
  local readonly server=${CONSUL_HTTP_ADDR:-localhost}
  echo "Checking consul @ $server"
  if consul info > /dev/null 2>&1; then
    return 0
  fi
  return 1
}

# get a single value
consul::get()
{
  local key=$1 || return
  value=$(consul kv get $key 2>/dev/null)
  echo $value
}

consul::set()
{
  local key=$1 || return
  local value=$2 || return
  value=$(consul kv put "$key" "$value" 2>/dev/null)
  return $?
}


# Save a key in a file
consul::save()
{
  local key=$1 || return
  local file=$2 || return
  if [[ -f $file ]]; then
    return 1
  fi
  consul kv get $key > $file
  if [[ $? -gt 0 ]]; then
     echo "Error getting value from consul for key '$key'"
     return 1
  elif [[ ! -f $file ]]; then
     echo "Error writing file '$file' from key '$key'"
     return 1
  fi
  return 0
}

# list keys in a folder
consul::list_folder()
{
  local key=$1 || return
  local -a result=()

  key="$key/"
  # the grep is required to remove the folders
  # that are returned by the get command and
  # that ends in /
  values=$(consul kv get -keys $key | egrep -v "^${key}$")
  for value in $values
  do
    result+=( "$value" )
  done
  if [[ ${#result[@]} -gt 0 ]]; then
    echo ${result[@]}
  fi
  return
}

# check if a key exists
consul::exists()
{
  local key=$1
  if consul kv get $key >/dev/null 2>&1; then
    return 0
  fi
  return 1
}

# check if a folder exists
consul::folder_exists()
{
  local readonly folder=$1
  local readonly father=$(dirname $folder)
  local readonly folder_name=$(basename $folder)
  local folders=$(consul::list_folder $father)
  for item in $folders
  do
    item_name=$(basename $item)
    if [[ $folder_name == $item_name ]]; then
      return 0
    fi
  done
  return 1
}

# import a text file into a key
consul::load()
{
  local file=$1 || return
  local key=$2 || return

  if [[ ! -f $file ]]; then
    return 1
  fi
  consul kv put "${key}" @${file}
  return $?
}

consul::remove_folder()
{
  local readonly folder=$1
  consul kv delete -recurse $folder
  return $?
}

consul::semaphore::init()
{
  name=${1:?"Missing session name"}
  http PUT $(consul::server)/v1/session/create name=${name}
}

consul::semaphore()
{
  echo 
}
