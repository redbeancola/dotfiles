#!/bin/sh
nvidia-smi --query-gpu=temperature.gpu,memory.used,power.draw,utilization.gpu --format=csv,noheader,nounits | awk -F', ' '{
    printf "%s°C         %sM         %sW        %s%%\n", $1, $2, $3, $4
}'
