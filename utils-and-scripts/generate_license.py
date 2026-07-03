#!/usr/bin/env python3
import jwt
import datetime
import sys
import os

def generate():
    # Coleta os parâmetros enviados pelo painel do GitHub Actions
    client_name = os.getenv("CLIENT_NAME")
    days_valid = os.getenv("DAYS_VALID")
    private_key_str = os.getenv("PROJEX_PRIVATE_KEY")

    if not client_name or not days_valid or not private_key_str:
        print("❌ Erro: Variáveis de ambiente obrigatórias ausentes.")
        sys.exit(1)

    try:
        days = int(days_valid)
        expiration = datetime.datetime.utcnow() + datetime.timedelta(days=days)
        
        # Estrutura de dados imutável da licença do cliente
        payload = {
            "iss": "Projex-Licensing-Authority",
            "sub": client_name.strip(),
            "iat": datetime.datetime.utcnow(),
            "exp": expiration,
            "tier": "Enterprise-Multitenant"
        }
        
        # Assina digitalmente o token usando a sua Chave Privada RSA
        token = jwt.encode(payload, private_key_str, algorithm="RS256")
        
        # Salva o arquivo de licença final que será injetado no Kubernetes do cliente
        with open("projex.lic", "w") as f:
            f.write(token)
            
        print(f"✅ Licença gerada com sucesso para: {client_name}")
        print(f"📅 Válida por {days} dias (Expira em: {expiration.strftime('%Y-%m-%d %H:%M:%S')} UTC)")
        
    except Exception as e:
        print(f"❌ Falha crítica ao gerar licença: {e}")
        sys.exit(1)

if __name__ == "__main__":
    generate()
