#!/usr/bin/env zsh
function _my_async_segment_compute() {
  (( EPOCHREALTIME >= _my_async_segment_next_time )) || return
  async_job _my_async_segment_worker _my_async_segment_async $PWD
  _my_async_segment_next_time=$((EPOCHREALTIME + 5))
}

function _my_async_segment_async() {
  local working_directory=$1
  sleep 1
  local result="$(date +'%H:%M:%S')"
  echo $working_directory
  echo $result
}

function _my_async_segment_callback() {
  local return_values=(${(f)3})
  local working_directory=$return_values[1]
  local result=$return_values[2]
  _my_async_segment_result[$working_directory]=$result
  zle reset-prompt
  zle -R
}

typeset -g -A _my_async_segment_result
typeset -gF _my_async_segment_next_time=0

async_init
async_stop_worker _my_async_segment_worker
async_start_worker _my_async_segment_worker -n
async_unregister_callback _my_async_segment_worker
async_register_callback _my_async_segment_worker _my_async_segment_callback

function prompt_my_async_segment() {
  _my_async_segment_compute

  local result="$_my_async_segment_result[$PWD]"

  local state="PRESENT"
  if [[ -z $result ]]; then
    state="ABSENT"
  fi
  
  p10k segment -s $state -f blue -c "$result" -t "async:$result"
}

