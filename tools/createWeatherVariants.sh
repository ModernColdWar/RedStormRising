#!/usr/bin/env bash
# Usage: createWeatherVariants.sh <templateMission> <weatherVariant1> [<weatherVariants> ...]
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
TEMPLATE_MIZ=$1
shift  # remove first argument from $@

echo Creating weather variants of $TEMPLATE_MIZ

$DIR/unpack.sh $TEMPLATE_MIZ >/dev/null

for arg; do
  $DIR/unpack.sh $arg >/dev/null
  lua.exe $DIR/copyDateAndWeather.lua ${arg%.*} ${TEMPLATE_MIZ%.*}
  $DIR/pack.sh ${arg%.*} >/dev/null
  echo Copying ${TEMPLATE_MIZ%.*} to ${TEMPLATE_MIZ%.*}-${arg%.*}
  cp -ar ${TEMPLATE_MIZ%.*} ${TEMPLATE_MIZ%.*}-${arg%.*}
  $DIR/pack.sh ${TEMPLATE_MIZ%.*}-${arg%.*} >/dev/null
done

$DIR/pack.sh ${TEMPLATE_MIZ%.*} >/dev/null

