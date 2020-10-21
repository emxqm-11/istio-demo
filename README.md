# istio-demo

Follow the steps sequentially.

### Prereqs

you need minikube & kubectl installed!!!

```
minikube start
```

### downloading istio

```
make download
```

change the VERSION to the latest version you downloaded in the Makefile variables section.

### installing istio

```
make install
make install.addons
```

### Deploy istio bookinfo app

```
make bookinfo.gw
```

### Services of type LoadBalancer can be exposed via the minikube tunnel command.

```
minikube tunnel
```

### Export Variables

```
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export INGRESS_HOST=$(minikube ip)
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
echo "$GATEWAY_URL"
```

Access the app at \$GATEWAY_URL/productpage!

#### istio add ons

```
istioctl dashboard kiali
istioctl dashboard jaeger
istioctl dashboard grafana
istioctl dashboard prometheus
```

- note if you get broken pipe errors from running these commands locally, just ctrl+c and run the command again.

#### istio jwt authentication

```
## apply jwt auth on ingressgateway
make jwt.ingress

## hit authenticated ingress endpoint
make jwt.hit

## cleanup
make jwt.cleanup
```

#### simulate hitting the ingress 100x

```
make generate.trace
```
