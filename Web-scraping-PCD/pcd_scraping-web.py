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

# Dictionnaire pour stocker les liens de recettes pour chaque catégorie
all_recipes_links = {category: [] for category in categories}

# Boucle sur chaque catégorie
for category, data in categories.items():
    base_url = data["url"]
    num_pages = data["pages"]
    
    for page in range(1, num_pages + 1):  # Boucle de page 1 à num_pages
        # Construire l'URL de la page en fonction de la page courante
        url = f"{base_url}-page-{page}" if page > 1 else base_url
        response = requests.get(url)
        
        # Si la page n'existe pas (réponse 404 ou autre erreur), on arrête la boucle
        if response.status_code != 200:
            print(f"Erreur sur la page {page} de {category}, arrêt de l'extraction.")
            break

        # Utilisation de BeautifulSoup pour parser la page HTML
        soup = BeautifulSoup(response.text, "html.parser")
        
        # Extraire les liens des recettes dans cette page
        recipe_links = [
            "https://www.ptitchef.com" + a["href"]
            for a in soup.select("div.i-data h2 a.stretched-link")
        ]
        
        # Si aucune recette n'est trouvée, on arrête la boucle pour cette catégorie
        if not recipe_links:
            print(f"{category} - Page {page} : Pas de liens trouvés, fin de l'extraction.")
            break
        
        # Ajouter les liens extraits dans le dictionnaire
        all_recipes_links[category].extend(recipe_links)
        
        print(f"{category} - Page {page} : {len(recipe_links)} liens trouvés")

# Convertir le dictionnaire de liens en un DataFrame
df = pd.DataFrame([(category, link) for category, links in all_recipes_links.items() for link in links], columns=["Category", "Recipe_Link"])

# Afficher les premières lignes du DataFrame
print(df.head())

# Sauvegarder le DataFrame dans un fichier CSV
df.to_csv("recipe_links.csv", index=False)

# Affichage du total des liens trouvés pour chaque catégorie
for category, links in all_recipes_links.items():
    print(f"Total des liens trouvés pour {category}: {len(links)}")

