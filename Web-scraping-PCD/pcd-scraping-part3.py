import requests
from bs4 import BeautifulSoup
import csv

# Fichier contenant les liens des recettes
input_csv = "recipe_links_filtered.csv" # Ce fichier doit contenir deux colonnes : "Catégorie", "URL"
output_csv = "recettes.csv"  # Fichier de sortie

# Lire les liens des recettes depuis le CSV
with open(input_csv, newline='', encoding='utf-8') as csvfile:
    reader = csv.reader(csvfile)
    next(reader)  # Ignorer l'en-tête
    recipe_links = list(reader)

# Liste pour stocker les données des recettes
recettes_data = []

# Boucle sur chaque recette
for category, url in recipe_links:
    print(f"Scraping : {url}")

    response = requests.get(url)
    if response.status_code != 200:
        print(f"Erreur {response.status_code} pour {url}")
        continue

    soup = BeautifulSoup(response.text, 'html.parser')

    # Extraction du nom de la recette
    nom_recette = soup.find('h1', class_='title animated fadeInDown')
    nom_recette = nom_recette.text.strip() if nom_recette else "Nom non trouvé"

    # Extraction des informations générales (temps, coût, etc.)
    info_dict = {}
    for item in soup.select('.rd-bar-ico .rdbi-item'):
        key = item.get('title', '').split(":")[0]
        value = item.find(class_='rdbii-val')
        if key and value:
            info_dict[key] = value.text.strip()

    # Extraction des ingrédients
    ingredients = [li.get_text(strip=True) for li in soup.select('.ingredients-ul li label')]

    # Extraction du coût estimé
    cout_total = soup.select_one('.e-cost-total')
    cout_par_part = soup.select_one('.e-cost-serving')
    cout_total = cout_total.text.strip() if cout_total else "Non spécifié"
    cout_par_part = cout_par_part.text.strip() if cout_par_part else "Non spécifié"

    # Extraction des temps de préparation et cuisson
    temps_prep = soup.select_one('.rd-times .rdt-item:nth-of-type(1)')
    temps_cuisson = soup.select_one('.rd-times .rdt-item:nth-of-type(2)')
    temps_prep = temps_prep.get_text(strip=True).replace("Préparation", "").strip() if temps_prep else "Non spécifié"
    temps_cuisson = temps_cuisson.get_text(strip=True).replace("Cuisson", "").strip() if temps_cuisson else "Non spécifié"

    # Extraction des étapes de préparation
    etapes = [li.get_text(" ", strip=True) for li in soup.select('.rd-steps li')]

    # Extraction des calories en évitant "Non spécifié"
    calories_general = info_dict.get("Calories")  # Depuis les informations générales
    calories_specifique_elem = soup.select_one('.nutrition-value') or soup.select_one('.nm-calories span:last-child')

    if calories_general and calories_general.lower() != "non spécifié":
        calories = calories_general + " Kcal"
    elif calories_specifique_elem and "Kcal" in calories_specifique_elem.text:
        calories = calories_specifique_elem.text.strip()
    else:
        calories = "Non spécifié"

    # Extraction de l'image principale
    img_elem = soup.select_one('.carousel-item.active img')
    img_url = img_elem['src'] if img_elem else "Image non trouvée"
    if img_url.startswith("/"):
        img_url = "https://www.ptitchef.com" + img_url  # Corriger l'URL relative

    # Ajouter les données extraites dans une liste
    recettes_data.append({
        "Catégorie": category,
        "Nom": nom_recette,
        "Calories": calories,
        "Coût total": cout_total,
        "Coût par part": cout_par_part,
        "Temps de préparation": temps_prep,
        "Temps de cuisson": temps_cuisson,
        "Ingrédients": "; ".join(ingredients),  # Stocker sous forme de chaîne séparée par ";"
        "Étapes": " | ".join(etapes),  # Séparer les étapes par "|"
        "Image": img_url,
        "URL": url
    })

# Sauvegarde des résultats dans un fichier CSV
with open(output_csv, 'w', newline='', encoding='utf-8') as csvfile:
    fieldnames = ["Catégorie", "Nom", "Calories", "Coût total", "Coût par part", "Temps de préparation",
                  "Temps de cuisson", "Ingrédients", "Étapes", "Image", "URL"]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(recettes_data)

print(f"Extraction terminée ! Les recettes ont été enregistrées dans {output_csv}")
