#!/bin/bash
echo ">> Forcing single thread ON...";
echo ">> --------------------------------------------------------------------------------";

echo ">> was: '$MT_THREAD_POOL_SIZE'.";

export MT_THREAD_POOL_SIZE="1";

echo ">> now: '$MT_THREAD_POOL_SIZE'.";

echo ">> --------------------------------------------------------------------------------";
echo ">> Forcing single thread ON... DONE";
