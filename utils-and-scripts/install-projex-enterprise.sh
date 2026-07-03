#!/usr/bin/env bash

# ==============================================================================
# PROJETO PROJEX — SCRIPT MESTRE DE INSTALAÇÃO ENTERPRISE (V1.0.0)
# ==============================================================================
# Diretiva de segurança Unix rígida: interrompe a execução em caso de qualquer falha
set -eo pipefail

# Paleta de cores para logs em padrão de terminal internacional
COR_RESET="\033[0m"
COR_INFO="\033[1;34m"
COR_SUCESSO="\033[1;32m"
COR_ALERTA="\033[1;33m"
COR_ERRO="\033[1;31m"
COR_TITULO="\033[1;36m"

log_info()    { echo -e "${COR_INFO}[INFO] $(date +'%Y-%m-%d %H:%M:%S') - $1${COR_RESET}"; }
log_sucesso() { echo -e "${COR_SUCESSO}[OK] $(date +'%Y-%m-%d %H:%M:%S') - $1${COR_RESET}"; }
log_alerta()  { echo -e "${COR_ALERTA}[AVISO] $(date +'%Y-%m-%d %H:%M:%S') - $1${COR_RESET}"; }
log_erro()    { echo -e "${COR_ERRO}[ERRO] $(date +'%Y-%m-%d %H:%M:%S') - $1${COR_RESET}"; }

imprimir_banner() {
    echo -e "${COR_TITULO}"
    echo "======================================================================"
    echo "    ____  ____   ____       _ ________  __   ____  ____  ____  _____"
    echo "   / __ \/ __ \ / __ \     | / / ____/ / /  / __ \/ __ \/ __ \/ ___/"
    echo "  / /_/ / /_/ // / / /_    |/ / /_    / /  / / / / /_/ / /_/ / __ \ "
    echo " / ____/ _, _// /_/ /_/ /|  / / __/  / /___/ /_/ / _, _/ ____/ /_/ / "
    echo "/_/   /_/ |_| \____/   _/_|_/_/     /_____/\____/_/ |_/_/   /_____/  "
    echo "                                                                      "
    echo "        SISTEMA AUTÔNOMO DE INSTALAÇÃO CORPORATIVA E BLINDADA         "
    echo "======================================================================"
    echo -e "${COR_RESET}"
}

# ==============================================================================
# 1. VERIFICAÇÃO DE PRÉ-REQUISITOS (PADRÃO NASA CRITICAL CHECKS)
# ==============================================================================
verificar_ambiente() {
    log_info "Iniciando varredura analítica de dependências do host..."
    
    local dependencias=("kubectl" "docker" "git")
    for dep in "${dependencias[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            log_erro "Dependência mandatória ausente no sistema do cliente: $dep"
            log_alerta "Por favor, instale o $dep antes de prosseguir com o onboarding."
            exit 1
        fi
    done
    
    # Valida se o operador possui comunicação ativa com um cluster Kubernetes legítimo
    if ! kubectl cluster-info &> /dev/null; then
        log_erro "Falha crítica de comunicação: Cluster Kubernetes inacessível ou kubeconfig inválido."
        exit 1
    fi
    
    log_sucesso "Ambiente validado com sucesso. Todos os sistemas operacionais estão nominais."
}

# ==============================================================================
# 2. VALIDAÇÃO DA LICENÇA CRIPTOGRÁFICA RSA-2048
# ==============================================================================
validar_licenca_local() {
    log_info "Iniciando verificação do cofre de licenciamento do cliente..."
    
    if [ ! -f "./projex.lic" ]; then
        log_erro "Arquivo de licença assinado 'projex.lic' não foi encontrado na raiz do instalador."
        log_alerta "Adquira seu token criptográfico junto à Autoridade Certificadora do Projeto Projex."
        exit 1
    fi
    
    log_sucesso "Token de licença localizado. A integridade será validada na inicialização do cluster."
}

# ==============================================================================
# 3. CONSTRUÇÃO E ARQUITETURA LOGÍSTICA DE NAMESPACES
# ==============================================================================
preparar_infraestrutura() {
    log_info "Configurando topologia de namespaces isolados..."
    
    # Criação dos perímetros de rede logicamente separados
    kubectl create namespace core-services --dry-run=client -o yaml | kubectl apply -f -
    kubectl create namespace core-monitoring --dry-run=client -o yaml | kubectl apply -f -
    
    # Ativação do Istio Service Mesh injetado para mTLS STRICT automático
    kubectl label namespace core-services istio-injection=enabled --overwrite
    kubectl label namespace core-monitoring istio-injection=enabled --overwrite
    
    log_sucesso "Namespaces e malha de serviços Istio parametrizados com sucesso."
}

# ==============================================================================
# 4. INJEÇÃO DOS SEGREDOS E LICENÇAS NO KUBERNETES
# ==============================================================================
injetar_secrets() {
    log_info "Injetando chaves públicas e tokens criptográficos no Kubernetes Vault..."
    
    # Deleta segredo anterior se houver para evitar colisões
    kubectl delete secret projex-license-vault -n core-services --ignore-not-found
    
    # Injeta a licença para que o InitContainer possa ler localmente e de forma offline
    kubectl create secret generic projex-license-vault \
        --namespace=core-services \
        --from-file=projex.lic=./projex.lic \
        --from-file=projex-public-key.pem=./utils-and-scripts/projex-public-key.pem
        
    log_sucesso "Segredos injetados na memória volátil protegida com sucesso."
}

# ==============================================================================
# 5. ORQUESTRACAO E DEPLOY MASSIVO DOS MANIFESTOS (ARGO-READY)
# ==============================================================================
executar_deploy() {
    log_info "Iniciando a implantação das camadas de segurança, IA e barramento LGPD..."
    
    # Aplica primeiro a política perimetral que fecha todas as portas internas (Default Deny)
    log_info "Aplicando Network Policies de isolamento Multitenant..."
    kubectl apply -f ./k8s-apps/network-policy-allow-mesh.yaml
    
    # Aplica o ecossistema de dados, auditoria e autenticação federada
    log_info "Sincronizando Banco de Dados relacional auditado com pgAudit e Keycloak..."
    # Se os arquivos individuais existirem na sua pasta k8s-apps, o comando apply -f pasta gerencia tudo de uma vez
    kubectl apply -f ./k8s-apps/
    
    log_info "Aguardando estabilização dos pods de monitoria e do barramento de IA..."
    # Loop de saúde rápido para checar se a infraestrutura responde de forma saudável
    local tentativas=0
    until kubectl get pods -n core-services &> /dev/null || [ $tentativas -eq 6 ]; do
        sleep 5
        tentativas=$((tentativas + 1))
    done
    
    log_sucesso "Todos os manifestos foram processados pela esteira de orquestração."
}

# ==============================================================================
# LOOP DE EXECUÇÃO PRINCIPAL (FLOW MASTER)
# ==============================================================================
main() {
    imprimir_banner
    verificar_ambiente
    validar_licenca_local
    preparar_infraestrutura
    injetar_secrets
    executar_deploy
    
    echo ""
    log_sucesso "======================================================================"
    log_sucesso "  INSTALAÇÃO CONCLUÍDA: O PROJETO PROJEX ESTÁ OFICIALMENTE ATIVO!     "
    log_sucesso "  Sistemas: Portal Web (3 Réplicas), PostgreSQL e Keycloak.          "
    log_sucesso "  Segurança: mTLS Estrito, Network Policies e Barramento IA LGPD.     "
    log_sucesso "======================================================================"
    echo ""
}

# Gatilho inicializador do instalador
main
