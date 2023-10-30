#!/usr/bin/env zsh
function _my_async_segment_compute() {
  # Check if it is time to call the background task
  (( EPOCHREALTIME >= _my_async_segment_next_time )) || return
  # Start background task
  async_job _my_async_segment_worker _my_async_segment_async $PWD
  # Set time for next execution
  _my_async_segment_next_time=$((EPOCHREALTIME + 5))
}

function _my_async_segment_async() {
  # Get parameters
  local working_directory=$1
  # Do something slow
  sleep 1
  local result="$(date +'%H:%M:%S')"
  # Output results
  echo $working_directory
  echo $result
}

function _my_async_segment_callback() {
  # Get result
  local return_values=(${(f)3})
  local working_directory=$return_values[1]
  local result=$return_values[2]
  # Store result in a global variable
  _my_async_segment_result[$working_directory]=$result
  # Uptate prompt
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

  # Expand result from global variables
  p10k segment -f blue -e -c '$_my_async_segment_result[$PWD]' -t 'async:$_my_async_segment_result[$PWD]'
}

