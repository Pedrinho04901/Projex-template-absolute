# ========================================================================
# ESTÁGIO 1: Construção e Compilação Criptográfica de Alta Performance
# ========================================================================
FROM python:3.11-alpine AS builder

WORKDIR /build

# Instala dependências de compilação necessárias para segurança militar
RUN apk add --no-cache gcc musl-dev libffi-dev openssl-dev

# Isola as bibliotecas de criptografia e IA corporativas
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ========================================================================
# ESTÁGIO 2: Runtime Imutável e Blindado (Padrão NASA Safety-Critical)
# ========================================================================
FROM python:3.11-alpine

# Criação de usuário e grupo restritos para conformidade regulatória e LGPD
RUN addgroup -S projexgroup && adduser -S projexuser -G projexgroup

WORKDIR /app

# Copia as bibliotecas otimizadas do estágio de compilação
COPY --from=builder /install /usr/local

# Copia os motores analíticos reais e inteligências artificiais do ecossistema
COPY utils-and-scripts/anonymizer.py /app/anonymizer.py
COPY utils-and-scripts/siem_guard.py /app/siem_guard.py
COPY utils-and-scripts/minerador.py /app/minerador.py

# 🔒 PROTEÇÃO ABSOLUTA: Transforma todo o código em apenas leitura (Anti-Malware)
RUN chown -R root:root /app && chmod -R 555 /app

# Executa o container com UID arbitrário de alta segurança (Não-Root)
USER 10001

# Gatilho de inicialização mestre
CMD ["python3", "anonymizer.py"]
