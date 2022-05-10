## Availability SLI
sum(rate(flask_http_request_total{status=~"2.."}[5m])) / sum(rate(flask_http_request_total[5m]))


## Latency SLI
### 90% of requests finish in these times
histogram_quantile(0.90, sum(rate(flask_http_request_duration_seconds_bucket[5m])) by (le, verb))


## Throughput
sum(rate(flask_http_request_total{status=~"2.."}[5m]))


## Error Budget - Remaining Error Budget
### The error budget is 20%
% error occurred = 1 - compliance  ->
```
1 - sum(increase(flask_http_request_total{status=~"2.."}[10m])) by (method) / sum(flask_http_request_total) by (method)
```
% error used = % error occurred/error budget ->
```
(1 - sum(increase(flask_http_request_total{status=~"2.."}[10m])) by (method) / sum(flask_http_request_total) by (method))/(1 - 0.8)
```
% remaining error budget = 1- % error used 
```
1 - ((1 - (sum(increase(flask_http_request_total{job="ec2", status=~"2.."}[7d])) by (verb)) /  sum(increase(flask_http_request_total{job="ec2"}[7d])) by (verb)) / (1 - .80))
```