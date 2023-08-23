# Deploy First Mentality

# Check to see if we can use ash, in Alpine images, or default to BASH.
SHELL_PATH = /bin/ash
SHELL = $(if $(wildcard $(SHELL_PATH)),/bin/ash,/bin/bash)

# ==============================================================================
# Define dependencies

GOLANG          := golang:1.21
ALPINE          := alpine:3.18
KIND            := kindest/node:v1.27.3
POSTGRES        := postgres:15.4
VAULT           := hashicorp/vault:1.14
GRAFANA         := grafana/grafana:9.5.3
PROMETHEUS      := prom/prometheus:v2.45.0
TEMPO           := grafana/tempo:2.2.0
LOKI            := grafana/loki:2.8.3
PROMTAIL        := grafana/promtail:2.8.3
TELEPRESENCE    := datawire/ambassador-telepresence-manager:2.14.2

KIND_CLUSTER    := amply-power-cluster
NAMESPACE       := cdr-system
APP             := cdr
BASE_IMAGE_NAME := amplypower/service
SERVICE_NAME    := cdr-api
VERSION         := 0.0.1
SERVICE_IMAGE   := $(BASE_IMAGE_NAME)/$(SERVICE_NAME):$(VERSION)


# ==============================================================================
# Install dependencies

dev-gotooling:
	go install github.com/divan/expvarmon@latest
	go install github.com/rakyll/hey@latest
	go install honnef.co/go/tools/cmd/staticcheck@latest
	go install golang.org/x/vuln/cmd/govulncheck@latest
	go install golang.org/x/tools/cmd/goimports@latest

dev-brew-common:
	brew update
	brew tap hashicorp/tap
	brew list kind || brew install kind
	brew list kubectl || brew install kubectl
	brew list kustomize || brew install kustomize
	brew list pgcli || brew install pgcli
	brew list vault || brew install vault

dev-brew: dev-brew-common
	brew list datawire/blackbird/telepresence || brew install datawire/blackbird/telepresence

dev-brew-arm64: dev-brew-common
	brew list datawire/blackbird/telepresence-arm64 || brew install datawire/blackbird/telepresence-arm64

dev-docker:
	docker pull $(GOLANG)
	docker pull $(ALPINE)
	docker pull $(KIND)
	docker pull $(POSTGRES)
	docker pull $(VAULT)
	docker pull $(GRAFANA)
	docker pull $(PROMETHEUS)
	docker pull $(TEMPO)
	docker pull $(LOKI)
	docker pull $(PROMTAIL)
	docker pull $(TELEPRESENCE)


# ==============================================================================
# Building containers

all: service

service:
	docker build \
		-f zarf/docker/dockerfile.service \
		-t $(SERVICE_IMAGE) \
		--build-arg BUILD_REF=$(VERSION) \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.


# ==============================================================================
# Running from within k8s/kind

dev-up-local:
	kind create cluster \
		--image $(KIND) \
		--name $(KIND_CLUSTER) \
		--config zarf/k8s/dev/kind-config.yaml

	kubectl wait --timeout=120s --namespace=local-path-storage --for=condition=Available deployment/local-path-provisioner

	kind load docker-image $(TELEPRESENCE) --name $(KIND_CLUSTER)
	kind load docker-image $(POSTGRES) --name $(KIND_CLUSTER)
	kind load docker-image $(VAULT) --name $(KIND_CLUSTER)
	kind load docker-image $(GRAFANA) --name $(KIND_CLUSTER)
	kind load docker-image $(PROMETHEUS) --name $(KIND_CLUSTER)
	kind load docker-image $(TEMPO) --name $(KIND_CLUSTER)
	kind load docker-image $(LOKI) --name $(KIND_CLUSTER)
	kind load docker-image $(PROMTAIL) --name $(KIND_CLUSTER)

dev-up: dev-up-local
	telepresence --context=kind-$(KIND_CLUSTER) helm install --request-timeout 2m 
	telepresence --context=kind-$(KIND_CLUSTER) connect

dev-down-local:
	kind delete cluster --name $(KIND_CLUSTER)

dev-down:
	telepresence quit -s
	kind delete cluster --name $(KIND_CLUSTER)
	

# ==============================================================================

dev-load:
	kind load docker-image $(SERVICE_IMAGE) --name $(KIND_CLUSTER)

dev-apply:
	kustomize build zarf/k8s/dev/cdr | kubectl apply -f -
	kubectl wait pods --namespace=$(NAMESPACE) --selector app=$(APP) --for=condition=Ready

dev-restart:
	kubectl rollout restart deployment $(APP) --namespace=$(NAMESPACE)

dev-update: all dev-load dev-restart

dev-update-apply: all dev-load dev-apply
	

# ==============================================================================

dev-logs:
	kubectl logs --namespace=$(NAMESPACE) -l app=$(APP) --all-containers=true -f --tail=100 --max-log-requests=6 | go run app/tooling/logfmt/main.go -service=$(SERVICE_NAME)

dev-status:
	kubectl get nodes -o wide
	kubectl get svc -o wide
	kubectl get pods -o wide --watch --all-namespaces

dev-describe-cdr:
	kubectl describe pod --namespace=$(NAMESPACE) -l app=$(APP)


# ==============================================================================

run:
	go run app/services/cdr-api/main.go | go run app/tooling/logfmt/main.go