# ssl_multiserver
SSL with the load balancer, as well as forcing https.

The approach is simple: we will run two servers in parallel
(not counting nodes within our cluster).

1. Our actual load balancer, serving only HTTPS requests. Use the `LoadBalancer.secure` constructor.
2. An HTTP server that redirects all incoming requests to the matching `https://` path.