🚨 PROJEX SECOPS: Master Disaster Recovery & Business Continuity Plan
Classificação: ESTRITAMENTE CONFIDENCIAL (Acesso Restrito - Nível C-Level & Lead Engineers)
Arquitetura de Recuperação: Terraform (IaC) + ArgoCD (GitOps) + Velero/MinIO (State Backup)
Mantido por: Projex Cloud Engineering

1. O Pior Cenário (Definição do Desastre)
A arquitetura da Projex é construída sob a premissa de que falhas de hardware não são uma possibilidade, são uma certeza estatística.

Este protocolo de emergência (Runbook Nível 0) é acionado exclusivamente em caso de Perda Total de Data Center (Ex: Região AWS us-east-1 offline) ou Comprometimento Total do Cluster (Ataque Zero-Day/Ransomware).

Acordos de Nível de Serviço (SLAs de Emergência)
RTO (Recovery Time Objective): < 15 minutos. O tempo máximo que a infraestrutura levará para ser recriada do zero absoluto em outra região do planeta.

RPO (Recovery Point Objective): < 15 minutos. A perda máxima de dados de estado (bancos de dados e volumes), garantida por snapshots contínuos. Para aplicações Stateless (código), o RPO é zero, pois o código é imutável no Git.

2. A Anatomia da Recuperação (Como o Sistema Sobrevive)
Não fazemos "backup de servidores". Servidores são descartáveis. Nós fazemos backup do estado (Dados) e declaramos a física (Infraestrutura) em código.

A recuperação depende de três pilares isolados:

GitHub (O Cérebro): Onde toda a infraestrutura e microsserviços estão gravados em pedra.

MinIO / Velero (O Cofre): Nosso bunker de armazenamento Air-Gapped rodando via ClusterIP. Ele guarda os snapshots dos volumes persistentes (PersistentVolumeClaims).

Terraform Cloud (O Construtor): A fábrica que recria a infraestrutura física em segundos.

3. Protocolo de Ignição (Passo a Passo da Recuperação)
No evento de uma catástrofe confirmada, o Líder de Engenharia (Projex) executará a seguinte sequência de comandos para ressuscitar a empresa do cliente em uma nova região intacta:

Fase 1: Reconstrução da Fundação (Terraform)
Abandonamos a região comprometida (ex: São Paulo) e apontamos nossa infraestrutura para uma nova zona de disponibilidade (ex: Virgínia).

Bash
# Navegar até o cofre de infraestrutura
cd 03-secops-governance/terraform-cloud-infra

# Forçar a recriação do cluster e redes na nova região
terraform plan -var="aws_region=us-east-1" -out=disaster_recovery.plan
terraform apply "disaster_recovery.plan"
Resultado: Em ~8 minutos, um novo cluster Kubernetes nasce, redes VPC são recriadas e as pontes de segurança (Security Groups) são restabelecidas.

Fase 2: Injeção do Cérebro GitOps (ArgoCD)
Com a nova máquina vazia no ar, injetamos a consciência dela.

Bash
# Apontar o cluster vazio para o repositório principal
kubectl apply -f 02-sre-resilience/bootstrap/root-application.yaml
Resultado: Em ~2 minutos, o ArgoCD baixa todo o ecossistema (Istio, microsserviços, políticas de segurança) e força o cluster a espelhar a produção original.

Fase 3: Restauração do Cofre de Dados (Velero + MinIO)
As aplicações subiram, mas os bancos de dados estão vazios. Conectamos o Velero ao nosso bunker MinIO sobrevivente para puxar a alma da empresa de volta.

Bash
# Listar os últimos backups salvos no MinIO instantes antes da queda
velero backup get

# Restaurar o último snapshot válido para dentro do novo cluster
velero restore create --from-backup <nome-do-ultimo-backup>
Resultado: Em ~3 minutos, os dados persistentes (Bancos de Dados, Filas e Storages Internos) são injetados nos Pods recém-criados.

Fase 4: Virada de Chave Perimetral (DNS)
A infraestrutura está 100% operacional no novo data center. Falta apenas avisar a internet.
O tráfego no provedor de DNS (ex: Cloudflare ou Route53) é atualizado para o IP do novo Istio Ingress Gateway. O TTL curto garantirá que os clientes voltem a acessar a plataforma imediatamente.

4. Auditoria e Validação (Pós-Morte)
Após a recuperação, o ambiente operará em "Estado de Alerta" por 24 horas.

Os robôs do Karpenter começarão a aquecer os motores para escalar horizontalmente conforme os usuários forem relogando no sistema.

Toda a malha mTLS do Istio emitirá novos certificados automaticamente para o novo cluster.

A operação é retomada. Fim do protocolo de contingência.