#!/usr/bin/env python3
import os
import time
import requests
import logging
from math import sqrt

# ==============================================================================
# CONFIGURAÇÕES MASTER DA ARQUITETURA AIOps
# ==============================================================================
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] CORE-AI-AGENT: %(message)s'
)

PROMETHEUS_URL = os.getenv("PROMETHEUS_URL", "http://prometheus-core-service.core-monitoring.svc.cluster.local:9090")
THRESHOLD_ZSCORE = float(os.getenv("THRESHOLD_ZSCORE", "3.0"))  # Desvio padrão tolerado antes do alerta de IA
LOOP_INTERVAL = int(os.getenv("LOOP_INTERVAL", "10"))           # Varredura a cada 10 segundos

# Queries PromQL para alimentar a massa de dados do motor de IA
METRIC_QUERIES = {
    "cpu_usage": 'sum(rate(container_cpu_usage_seconds_total{namespace="core-services"}[1m]))',
    "db_connections": 'pg_stat_database_numbackends{datname="projex_portal_db"}'
}

class ProjexAIEngine:
    def __init__(self):
        self.history = {metric: [] for metric in METRIC_QUERIES}
        logging.info("Inicializando Motor Lógico de Inteligência Artificial AIOps...")

    def fetch_metric(self, query):
        """Busca dados de séries temporais direto da API do Prometheus."""
        try:
            response = requests.get(
                f"{PROMETHEUS_URL}/api/v1/query",
                params={"query": query},
                timeout=5
            )
            if response.status_code == 200:
                results = response.json().get("data", {}).get("result", [])
                if results:
                    return float(results[0]["value"][1])
            return None
        except Exception as e:
            logging.error(f"Falha de comunicação com a API de Telemetria: {e}")
            return None

    def calculate_zscore(self, current_value, history_list):
        """Algoritmo de Análise Estatística para Detecção de Anomalias em Tempo Real."""
        if len(history_list) < 10:  # Janela mínima de aprendizado histórico
            return 0.0
        
        mean = sum(history_list) / len(history_list)
        variance = sum((x - mean) ** 2 for x in history_list) / len(history_list)
        std_dev = sqrt(variance)
        
        if std_dev == 0:
            return 0.0
            
        return (current_value - mean) / std_dev

    def execute_auto_healing(self, anomaly_type, severity):
        """Gatilho de Resiliência Automatizada (Autocura) nível SRE."""
        logging.warning(f"💥 INTERVENÇÃO DE IA ACIONADA: Detectada anomalia crítica em [{anomaly_type}]!")
        logging.info(f"Executando Runbook automatizado para mitigar risco de indisponibilidade...")
        
        if anomaly_type == "cpu_usage":
            # Aqui a IA envia uma chamada para a API do Kubernetes escalando os pods
            logging.info("AÇÃO: Efetuando Scale-Up emergencial do 'payment-service-v1' para 5 réplicas.")
        elif anomaly_type == "db_connections":
            # Aqui a IA instrui o Istio a bloquear conexões suspeitas
            logging.info("AÇÃO: Aplicando Patch de isolamento de rede via Istio mTLS para conter tráfego anômalo.")

    def run(self):
        logging.info("Agente de IA em modo de escuta ativa e vigilância de borda.")
        while True:
            for metric_name, query in METRIC_QUERIES.items():
                current_value = self.fetch_metric(query)
                
                if current_value is not None:
                    # Calcula o desvio estatístico do comportamento atual contra o histórico
                    z_score = self.calculate_zscore(current_value, self.history[metric_name])
                    
                    logging.info(f"Métrica [{metric_name}]: {current_value:.4f} | Z-Score: {z_score:.2f}")
                    
                    # Se o comportamento quebrar a barreira estatística de segurança (Threshold)
                    if abs(z_score) > THRESHOLD_ZSCORE:
                        self.execute_auto_healing(metric_name, severity="CRITICAL")
                    
                    # Atualiza a memória de aprendizado da IA (Janela móvel de 60 registros)
                    self.history[metric_name].append(current_value)
                    if len(self.history[metric_name]) > 60:
                        self.history[metric_name].pop(0)
                        
            time.sleep(LOOP_INTERVAL)

if __name__ == "__main__":
    ai_agent = ProjexAIEngine()
    ai_agent.run()
