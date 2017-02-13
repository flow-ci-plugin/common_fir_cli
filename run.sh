# ************************************************************
#
# This step will use fir-cli to publish your app
#
#   Variables used:
#     $FIR_API_TOKEN
#     $FIR_CHANGELOG
#     $FIR_APP_PATH
#
#   Outputs:
#     $FLOW_FIR_RESULT
#
# ************************************************************

set +e
source $HOME/.rvm/scripts/rvm
rvm use default

FLOW_BUILD_PROJECT_PATH=$FLOW_CURRENT_PROJECT_PATH
IFS=$'\n'
array=$(find $FLOW_BUILD_PROJECT_PATH -name *.apk -o -name *.ipa 2>&1)
function filter()
{
  local result
  for file in ${array[@]}
  do
    case "$1" in
      release)
        if [[ $file == *"release"* ]]; then
          echo "$file"
          return 1
        fi
        ;;
      debug_unaligned)
        var=$(echo $file| grep debug | grep -v unaligned 2>&1)
        if [ -n "$var" ]; then
          echo "$file"
          return 1
        fi
        ;;
      debug)
        if [[ $file == *"debug"* ]]; then
          echo "$file"
          return 1
        fi
        ;;
      *)
        echo "$file"
        return 1
    esac
  done
}
if [[ -z $FIR_APP_PATH ]]; then
  FLOW_BUILD_APP_PATH=$(filter "release" 2>&1)
  if [[ -z $FLOW_BUILD_APP_PATH ]]; then
    FLOW_BUILD_APP_PATH=$(filter "debug" 2>&1)
    if [[ -z $FLOW_BUILD_APP_PATH ]]; then
      FLOW_BUILD_APP_PATH=$(filter "debug_unaligned" 2>&1)
      if [[ -z $FLOW_BUILD_APP_PATH ]]; then
        FLOW_BUILD_APP_PATH=$(filter "random" 2>&1)
        if [[ -z $FLOW_BUILD_APP_PATH ]]; then
          echo "WARNING: can't find .apk file"
          exit 1
        fi
      fi
    fi
  fi
else
  FLOW_BUILD_APP_PATH=$FLOW_BUILD_PROJECT_PATH/$FIR_APP_PATH
fi

echo $FLOW_BUILD_APP_PATH

if [[ -z $FIR_API_TOKEN ]]; then
  echo "WARNING: the [FIR_API_TOKEN] not exist..."
  exit 1
fi

if [[ -f $FLOW_BUILD_APP_PATH ]]; then
  echo "FLOW_BUILD_APP_PATH exist"
else
  echo "WARNING: the [FLOW_BUILD_APP_PATH] not exist..."
  exit 1
fi

if [[ -z $FIR_CHANGELOG ]]; then
  FIR_CHANGELOG="$(date +%Y-%m-%d:%H:%M:%S): build from flow.ci"
fi

echo -e "ruby -v"
ruby -v

echo -e "gem -v"
gem -v

echo "install fir-cli"

fir version &> /dev/null 
if [ $? -ne 0 ]
then  
  gem install fir-cli --no-ri --no-rdoc
fi 



echo "fir-cli version"
fir --version

set -e
echo "fir publish [FLOW_BUILD_APP_PATH] -T [FIR_API_TOKEN] -c [FIR_CHANGELOG]"
fir publish $FLOW_BUILD_APP_PATH -c $FIR_CHANGELOG -T $FIR_API_TOKEN
