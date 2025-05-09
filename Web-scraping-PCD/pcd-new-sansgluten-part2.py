import time
import requests
from bs4 import BeautifulSoup
import csv

# Fichier contenant les liens des recettes
input_csv = "recipe_special_mode_links.csv"  # Ce fichier doit contenir deux colonnes : "Categories", "Recipe_Link"
output_csv = "recettes_speciales.csv"  # Fichier de sortie

# Lire les liens des recettes depuis le CSV
with open(input_csv, newline='', encoding='utf-8') as csvfile:
    reader = csv.reader(csvfile)
    next(reader)  # Ignorer l'en-tête
    recipe_links = list(reader)

# Liste pour stocker les données des recettes
recettes_data = []
recipe_cache = {}  # Cache pour éviter de scraper plusieurs fois la même recette

# Boucle sur chaque recette
for row in recipe_links:
    url = row[0]  # URL de la recette
    categories = row[1]  # Catégories associées

    # Vérifier si l'URL est valide (doit commencer par 'https')
    if not url.startswith('https'):
        print(f"Erreur : URL invalide {url}")
        continue

    print(f"Scraping : {url}")

    # Vérifier si l'URL a déjà été scrappée
    if url in recipe_cache:
        recette = recipe_cache[url]
    else:
        response = requests.get(url)
        if response.status_code != 200:
            print(f"Erreur {response.status_code} pour {url}")
            continue

        soup = BeautifulSoup(response.text, 'html.parser')

        # Extraction du nom de la recette
        nom_recette = soup.find('h1', class_='title animated fadeInDown')
        nom_recette = nom_recette.text.strip() if nom_recette else "Nom non trouvé"
        
        # Recherche du type de recette en ciblant la bonne classe
        type_recette_elem = soup.select_one('.rd-bar-ico .rdbi-item .rdbii-val')
        type_recette = type_recette_elem.text.strip() if type_recette_elem else "Type non spécifié"

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
            calories = calories_general
        elif calories_specifique_elem:
            calories = calories_specifique_elem.text.strip()
        else:
            calories = "Non spécifié"

        # Extraction de l'image principale
        img_elem = soup.select_one('.carousel-item.active img')
        img_url = img_elem['src'] if img_elem else "Image non trouvée"
        if img_url.startswith("/"):
            img_url = "https://www.ptitchef.com" + img_url

        # Ajouter la recette au cache
        recette = {
            "Nom": nom_recette,
            "Catégorie": type_recette,
            "Calories": calories,
            "Coût total": cout_total,
            "Coût par part": cout_par_part,
            "Temps de préparation": temps_prep,
            "Temps de cuisson": temps_cuisson,
            "Ingrédients": "; ".join(ingredients),
            "Étapes": " | ".join(etapes),
            "Image": img_url,
            "URL": url
        }
        recipe_cache[url] = recette

    # Ajouter la recette pour chaque catégorie liée
    categories = categories.split(",")  # Si plusieurs catégories sont séparées par une virgule
    for cat in categories:
        # Déterminer le type de régime basé sur la catégorie
        if "Sans gluten" in cat:
            type_regime = "Sans gluten"
        elif "Végétarien" in cat:
            type_regime = "Végétarien"
        elif "Allergie alimentaire" in cat:
            type_regime = "Allergie alimentaire"
        else:
            type_regime = "Autre"

        recettes_data.append({
            "Catégorie": cat.strip(),
            "Type de régime": type_regime,
            **recette  # Ajouter toutes les autres informations de la recette
        })

    # Ajout d'une pause de 1 seconde entre chaque requête pour éviter de surcharger le serveur
    time.sleep(1)

# Sauvegarde des résultats dans un fichier CSV
with open(output_csv, 'w', newline='', encoding='utf-8') as csvfile:
    fieldnames = ["Catégorie", "Type de régime", "Nom", "Calories", "Coût total", "Coût par part", "Temps de préparation",
                  "Temps de cuisson", "Ingrédients", "Étapes", "Image", "URL"]
    writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(recettes_data)

print(f"Extraction terminée ! Les recettes ont été enregistrées dans {output_csv}")

