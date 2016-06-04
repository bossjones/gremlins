#!/bin/sh

#
# Validate input:
#   ENTROPY_FAILURES
#     - present
#     - valid and defined by image
#   ENTROPY_FREQUENCY
#     - present
#     - in whole seconds
#   ENTROPY_PROBABILITY
#     - present
#     - decimal less than or equal to 1
#

if [ -z "$ENTROPY_PROBABILITY" ]; then
  echo >&2 '[ERROR]: specify ENTROPY_PROBABILITY environment variable'
  exit 1
fi

if [ -z "$ENTROPY_FREQUENCY" ]; then
  echo >&2 '[ERROR]: specify ENTROPY_FREQUENCY environment variable'
  exit 1
fi

if [ -z "$ENTROPY_FAILURES" ]; then
  echo >&2 '[ERROR]: specify ENTROPY_FAILURES environment variable'
  exit 1
fi

#
# Generate profile
#
ENTROPY_CLEAR_WEIGHT="$(echo 1 - $ENTROPY_PROBABILITY | bc)"
ENTROPY_FAILURE_WEIGHT=$ENTROPY_PROBABILITY
cat profile.tmpl | \
  sed "s/ENTROPY_SECONDS/${ENTROPY_FREQUENCY}/" | \
  sed "s/ENTROPY_FAILURE_WEIGHT/${ENTROPY_FAILURE_WEIGHT}/" | \
  sed "s/ENTROPY_CLEAR_WEIGHT/${ENTROPY_CLEAR_WEIGHT}/" | \
  sed "s/ENTROPY_FAILURE/${ENTROPY_FAILURES}/" \
  > ./gremlins/profiles/entropy.py

printf "[%s, %s, %s]" $ENTROPY_FAILURES $ENTROPY_FREQUENCY $ENTROPY_PROBABILITY

#
# Start gremlins
#
exec "$@" # run the default command
