# 🛡️ Projex SRE: Blueprint de GitOps & Progressive Delivery

**Classificação:** Confidencial / Uso Interno
**Arquitetura:** Kubernetes Multi-Tenant + ArgoCD + Istio Service Mesh
**Mantido por:** Projex Cloud Engineering

---

## 1. O Paradigma Declarativo (A Regra de Ouro)

Bem-vindo à nova fundação de infraestrutura da empresa. A partir de hoje, operamos sob o modelo de **GitOps Absoluto**. 

O cluster Kubernetes é estritamente **Imutável**. O acesso de escrita humana aos servidores de produção foi revogado por design para garantir 99.99% de disponibilidade.

🚨 **A REGRA DE OURO:** > É terminantemente proibido o uso de `kubectl apply`, `kubectl edit` ou `helm upgrade` diretamente contra o cluster de produção. 
> 
> O Git (este repositório) é a única Fonte da Verdade (Source of Truth). Qualquer alteração manual feita no servidor será tratada como *Configuration Drift* e será automaticamente esmagada e revertida pelo nosso controlador (ArgoCD) em menos de 3 minutos.

---

## 2. O Fluxo de Deploy (Caminho Feliz)

Para colocar uma nova versão do seu aplicativo no ar, sua equipe não precisa se preocupar com a infraestrutura. Siga este fluxo:

1. **Altere o Manifesto:** Atualize a tag da imagem Docker no seu arquivo de deployment dentro de `02-sre-resilience/platform-apps/`.
2. **Commit & Push:** Faça o push do código para a branch `main`.
3. **Reconciliação Automática:** O ArgoCD detectará o novo commit e iniciará a sincronização com o cluster silenciosamente.

---

## 3. Canary Release: A Rede de Segurança

Para garantir "Risco Zero", não substituímos 100% da aplicação de uma vez. Utilizamos as regras de roteamento do **Istio Service Mesh** (definidas em `platform-routing/traffic-splitting.yaml`).

Quando o ArgoCD sincroniza a nova versão (`app-v2-canary`), o seguinte comportamento físico ocorre na rede:
* **90% do Tráfego** continua roteado para a versão antiga e estável (`Stable`).
* **10% do Tráfego** é desviado para a sua nova versão (`Canary`).

**Validação:** Acompanhe o dashboard de telemetria da Projex (Grafana). Se a latência ou a taxa de erros HTTP 5xx subir nos 10% do Canary, o deploy está quebrado. 

---

## 4. Procedimento de Rollback de Emergência

Se a versão Canary apresentar falhas catastróficas, o Rollback é feito em segundos, sem tocar no cluster:

1. **Abortar via Git:** Execute `git revert <hash-do-ultimo-commit>` no seu terminal local.
2. **Push da Correção:** Faça o `git push` para a branch `main`.
3. **Estabilização:** O ArgoCD lerá a reversão, destruirá os pods defeituosos e voltará a rotear 100% do tráfego para a versão anterior, estabilizando o ambiente sem queda total do sistema.

**Incidentes Críticos:** Em caso de perda de comunicação com o GitHub ou catástrofe de rede, acione a linha direta do **Suporte VIP Projex** via WhatsApp para intervenção manual com privilégios de *Cluster Admin*.