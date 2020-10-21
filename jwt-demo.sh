#!/bin/bash
export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
export INGRESS_HOST=$(minikube ip)
export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
export TOKEN=$(curl https://raw.githubusercontent.com/istio/istio/release-1.7/security/tools/jwt/samples/demo.jwt -s)

echo "==========================="
echo "Jwt with INVALID token" 
echo "==========================="
echo ""
echo "Response Code: " 
curl --header "Authorization: Bearer deadbeef" "$INGRESS_HOST:$INGRESS_PORT/productpage" -s -o /dev/null -w "%{http_code}\n"

echo 
echo
echo "==========================="
echo "Jwt with NO token" 
echo "==========================="
echo ""
echo "Response Code: " 
curl "$INGRESS_HOST:$INGRESS_PORT/productpage" -s -o /dev/null -w "%{http_code}\n"
echo
echo

echo "==========================="
echo "jwt with VALID token"
echo "==========================="
echo "Response Code: "
curl --header "Authorization: Bearer $TOKEN" "$INGRESS_HOST:$INGRESS_PORT/productpage" -s -o /dev/null -w "%{http_code}\n"
echo
echo