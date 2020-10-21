.SILENT:
.ONESHELL:
SHELL=/bin/bash
.DEFAULT_GOAL := help
.PHONY: help

# VARIABLES =================================
# ===========================================
VERSION=istio-1.7.2

# FUNCTIONS =================================
# ===========================================
download: ## download latest istio
	curl -L https://istio.io/downloadIstio | sh -

install: ## install demo profile 
	istioctl install --set profile=demo --set values.global.istiod.enableAnalysis=true

install.addons:
	kubectl apply -f $(VERSION)/samples/addons
	while ! kubectl wait --for=condition=available --timeout=600s deployment/kiali -n istio-system; do sleep 1; done

label.ns: ## label namespace for sidecars
	kubectl label namespace default istio-injection=enabled

bookinfo: label.ns ## deploy sample bookinfo app
	kubectl apply -f $(VERSION)/samples/bookinfo/platform/kube/bookinfo.yaml

bookinfo.gw: bookinfo
	kubectl apply -f $(VERSION)/samples/bookinfo/networking/bookinfo-gateway.yaml

## please run this manually in your terminal as makefile's child processes don't work if you just export like this 
minikube.exports: 
	minikube tunnel
	export INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="http2")].nodePort}')
	export SECURE_INGRESS_PORT=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.spec.ports[?(@.name=="https")].nodePort}')
	export INGRESS_HOST=$(minikube ip)
	export GATEWAY_URL=$INGRESS_HOST:$INGRESS_PORT
	echo "$GATEWAY_URL"

jwt.ingress:
	kubectl apply -f ./ingress-request-authorisation.yaml
	kubectl apply -f ./ingress-authorisation-policy.yaml

jwt.cleanup:
	kubectl -n istio-system delete requestauthentication jwt-example
	kubectl -n istio-system delete authorizationpolicy frontend-ingress

jwt.hit:
	./jwt-demo.sh

generate.trace:
	./hit-website.sh

analyse.badgw:
	istioctl analyze ./bad-bookinfo-gateway.yaml
# HELPER FUNCTIONS ==========================
# ===========================================
help: help.variables help.available_functions

help.variables:
	echo "== Variables for Installation"
	echo VERSION 

help.available_functions:
	echo "================================="
	fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'
	echo "================================="
