#!/bin/bash
echo ">> Forcing single thread OFF...";
echo ">> --------------------------------------------------------------------------------";

echo ">> was: '$MT_THREAD_POOL_SIZE'.";

unset MT_THREAD_POOL_SIZE;

echo ">> now: '$MT_THREAD_POOL_SIZE'.";

echo ">> --------------------------------------------------------------------------------";
echo ">> Forcing single thread OFF... DONE";
