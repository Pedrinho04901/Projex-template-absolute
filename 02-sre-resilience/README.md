# Enterprise GitOps & Service Mesh Infrastructure Platform 🚀

[![Kubernetes](https://img.shields.io/badge/Kubernetes-v1.28+-326CE5?logo=kubernetes&logoColor=white)](https://kubernetes.io)
[![ArgoCD](https://img.shields.io/badge/GitOps-ArgoCD-FF6700?logo=argo&logoColor=white)](https://argoproj.github.io/cd/)
[![Istio](https://img.shields.io/badge/Service_Mesh-Istio-466BB0?logo=istio&logoColor=white)](https://istio.io)
[![License](https://img.shields.io/badge/Platform-Enterprise-blue)](#)

Este repositório contém a especificação declarativa de uma **Plataforma de Infraestrutura Global Cloud-Native**, projetada sob os padrões rigorosos de resiliência, segurança e automação exigidos por multinacionais. 

A arquitetura adota a filosofia de **Platform Engineering**, segregando as definições de infraestrutura de rede, políticas de segurança (*Service Mesh*) e os ciclos de vida dos microsserviços através de **GitOps Multi-Tenant**.

---

## 🏗️ Arquitetura do System

A topologia da plataforma é baseada no ecossistema **CNCF (Cloud Native Computing Foundation)**, mitigando o acoplamento com provedores de nuvem específicos (*Cloud Agnostic*):

```text
[ Tráfego Externo (api.enterprise.com) ]
                  │
                  ▼
      [ Istio Ingress Gateway ]
                  │
                  ├──────────────────────────────┐
       (90% do Tráfego via mTLS)      (10% do Tráfego via mTLS)
                  │                              │
                  ▼                              ▼
        [ payment-service:v1 ]         [ payment-service:v2 ]
          (Stable Deployment)            (Canary Deployment)
Componentes Core da Plataforma:
Orquestração & GitOps (ArgoCD): Implementação do padrão App-of-Apps com reconciliação automatizada (Self-Healing) e descarte em cascata para evitar desvios de configuração (Configuration Drift).

Malha de Serviços (Istio Service Mesh): Camada de rede responsável por gerenciar a comunicação leste-oeste (inter-pod) sob o modo mTLS STRICT, garantindo criptografia mútua de nível bancário sem alterações no código da aplicação.

Estratégia de Deploy Avançada (Canary Release): Divisão matemática de tráfego injetada via recursos customizados do Istio (VirtualService e DestinationRule), encaminhando 90% das requisições para o cluster produtivo e 10% para a versão avaliada.

📂 Estrutura de Diretórios Enterprise
A governança do repositório divide estritamente as responsabilidades de controle de tráfego, segurança e deployments:

Plaintext
enterprise-gitops-infra/
├── bootstrap/
│   └── root-application.yaml          # Ponto de entrada do ArgoCD (App-of-Apps)
├── platform-apps/
│   ├── app-v1-deployment.yaml         # Stateful real / Deployment estável (3 réplicas)
│   └── app-v2-canary-deployment.yaml  # Ambiente controlado Canary (1 réplica)
└── platform-routing/
    ├── enterprise-gateway.yaml        # Configuração do Ingress Gateway perimetral
    └── traffic-splitting.yaml         # Políticas de split de tráfego por peso e mTLS
🛠️ Requisitos de Ambiente Local
Para instanciar esta plataforma localmente a custo zero, o ambiente simula as restrições de produção através de isolamento por containers:

Docker ou Moby Engine

K3d CLI (Engine leve do Kubernetes certificado pela CNCF)

Helm CLI v3

Kubectl CLI

🚀 Guia de Implantação Automatizado (Runbook)
Execute a sequência de comandos abaixo em seu terminal para provisionar a infraestrutura completa do zero:

1. Inicialização do Cluster Multi-Node
Criamos o cluster desativando os controladores padrão de entrada (como o Traefik) para que o Istio assuma o controle total da camada de borda:

Bash
k3d cluster create global-infra \
  -p "80:80@loadbalancer" \
  -p "443:443@loadbalancer" \
  --k3s-arg "--disable=traefik@server:0"
2. Implantação da Malha Istio (Enterprise Network Profile)
Bash
kubectl create namespace istio-system
helm repo add istio [https://istio-release.storage.googleapis.com/charts](https://istio-release.storage.googleapis.com/charts)
helm repo update
helm install istio-base istio/base -n istio-system
helm install istiod istio/istiod -n istio-system --wait
helm install istio-ingress istio/gateway -n istio-system
3. Provisionamento do ArgoCD (GitOps Controller)
Bash
kubectl create namespace argocd
kubectl apply -n argocd -f [https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml](https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml)
4. Configuração do Tenant e Injeção Automática de Proxy Sidecar
Instruímos o Kubernetes a injetar automaticamente o proxy do Istio (Envoy) em qualquer pod que nasça no namespace produtivo:

Bash
kubectl create namespace core-services
kubectl label namespace core-services istio-injection=enabled
5. Ativação do Loop de Reconciliação (O Pontapé Inicial)
Aplique o arquivo de bootstrap apontando para este repositório para que o ArgoCD assuma o controle declarativo do ambiente:

Bash
kubectl apply -f bootstrap/root-application.yaml
🔒 Engenharia de Resiliência Demonstrada
Zero Downtime: As atualizações do payment-service utilizam a estratégia RollingUpdate com maxSurge: 1 e maxUnavailable: 0, garantindo estabilidade absoluta.

Criptografia na Camada 7: Toda a comunicação interna usa certificados TLS rotacionados dinamicamente via Istio CA.

Segurança de Recursos: Todos os manifestos possuem limites estritos de consumo de Hardware (Limits e Requests de CPU e Memória) para mitigar vetores de ataques de negação de serviço interno (Noisy Neighbor effect).

Mantido com foco em Engenharia de Plataforma de Alta Escala.
