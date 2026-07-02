from duckduckgo_search import DDGS

alvo_pesquisa = 'site:linkedin.com/in/ ("CTO" OR "Tech Lead") "Fintech" "São Paulo"'
quantidade_de_leads = 20

print("🚀 Iniciando os motores via DuckDuckGo...")
print("Buscando alvos estratégicos...\n")

try:
    with DDGS() as ddgs:
        resultados = ddgs.text(alvo_pesquisa, max_results=quantidade_de_leads)
        
        if not resultados:
            print("Nenhum resultado encontrado. Tente simplificar os termos de busca.")
            
        for i, r in enumerate(resultados, start=1):
            # Imprime o título da página e o link do LinkedIn
            print(f"[Lead {i}] {r.get('title')}")
            print(f"Link: {r.get('href')}\n")
            
except Exception as e:
    print(f"Erro na extração: {e}")

print("✅ Busca finalizada!")