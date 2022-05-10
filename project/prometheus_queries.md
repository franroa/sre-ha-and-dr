## Availability SLI
sum(rate(flask_http_request_total{status=~"2.."}[5m])) / sum(rate(flask_http_request_total[5m]))


## Latency SLI
### 90% of requests finish in these times
histogram_quantile(0.90, sum(rate(flask_http_request_duration_seconds_bucket[5m])) by (le, verb))


## Throughput
sum(rate(flask_http_request_total{status=~"2.."}[5m]))


## Error Budget - Remaining Error Budget
### The error budget is 20%
1 - ((1 - (sum(increase(flask_http_request_total{status=~"2.."}[10m])) by (verb)) / sum(increase(flask_http_request_total[10m])) by (verb)) / (1 - .80))

