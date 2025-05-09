import requests
from bs4 import BeautifulSoup
import pandas as pd

# Dictionnaire des catégories avec leur URL de base et le nombre de pages à parcourir
categories = {
    "Apéritif": {"url": "https://www.ptitchef.com/recettes/aperitif", "pages": 42},
    "Entrée": {"url": "https://www.ptitchef.com/recettes/entree", "pages": 42},
    "Plat": {"url": "https://www.ptitchef.com/recettes/plat", "pages": 42},
    "Dessert": {"url": "https://www.ptitchef.com/recettes/dessert", "pages": 42},
    "Goûter": {"url": "https://www.ptitchef.com/recettes/gouter", "pages": 42},
    "Boisson": {"url": "https://www.ptitchef.com/recettes/boisson", "pages": 22},
    "Accompagnement": {"url": "https://www.ptitchef.com/recettes/accompagnement", "pages": 19},
    "Autre": {"url": "https://www.ptitchef.com/recettes/autre", "pages": 42},
    "Recettes de saison": {"url": "https://www.ptitchef.com/recettes/recettes-de-saison", "pages": 70}
}

# Dictionnaire pour stocker les liens uniques et leurs catégories associées
recipe_links_dict = {}

# Headers pour éviter d'être bloqué par le site
headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36"
}

# Fonction pour vérifier si une URL est valide
def is_valid_url(url):
    try:
        response = requests.head(url, headers=headers, timeout=5)
        return response.status_code == 200
    except requests.RequestException:
        return False

# Boucle sur chaque catégorie
for category, data in categories.items():
    base_url = data["url"]
    num_pages = data["pages"]

    for page in range(1, num_pages + 1):
        url = f"{base_url}-page-{page}" if page > 1 else base_url
        
        try:
            response = requests.get(url, headers=headers, timeout=10)

            if response.status_code != 200:
                print(f"⚠️ {category} - Page {page} : Erreur {response.status_code}, on passe à la suivante.")
                continue

            # Parser la page HTML avec BeautifulSoup
            soup = BeautifulSoup(response.text, "html.parser")

            # Extraire les liens des recettes
            raw_links = [
                "https://www.ptitchef.com" + a["href"]
                for a in soup.select("div.i-data h2 a.stretched-link")
            ]

            # Vérifier chaque lien et ne garder que les liens valides
            valid_links = {link for link in raw_links if is_valid_url(link)}

            # Stocker les liens dans le dictionnaire avec les catégories associées
            for link in valid_links:
                if link not in recipe_links_dict:
                    recipe_links_dict[link] = set()  # Créer un set pour stocker les catégories
                recipe_links_dict[link].add(category)  # Ajouter la catégorie

            print(f" {category} - Page {page} : {len(valid_links)} liens valides ajoutés.")

        except requests.RequestException as e:
            print(f" {category} - Page {page} : Erreur de requête ({e}), on passe à la suivante.")

# Convertir le dictionnaire en DataFrame
df = pd.DataFrame(
    [(link, ", ".join(categories)) for link, categories in recipe_links_dict.items()], 
    columns=["Recipe_Link", "Categories"]
)

# Sauvegarde en CSV
df.to_csv("recipe_links_filtered.csv", index=False)

# Affichage des statistiques
print("\n Résumé des liens collectés :")
for category in categories.keys():
    count = sum(1 for cats in recipe_links_dict.values() if category in cats)
    print(f"{category}: {count} recettes trouvées.")

print("\n Extraction terminée ! Le fichier 'recipe_links_filtered.csv' est prêt.")
