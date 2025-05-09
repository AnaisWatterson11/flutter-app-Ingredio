import requests
from bs4 import BeautifulSoup
import csv

# Définir l'URL spécifique à scraper
url = "https://www.ptitchef.com/recettes/gouter/fondant-au-chocolat-et-haricots-rouges-fid-1570481"

print(f"Scraping : {url}")

# Envoyer une requête HTTP
response = requests.get(url)
if response.status_code != 200:
    print(f"Erreur {response.status_code} pour {url}")
else:
    soup = BeautifulSoup(response.text, 'html.parser')

    # Extraction du nom de la recette
    nom_recette = soup.find('h1', class_='title animated fadeInDown')
    nom_recette = nom_recette.text.strip() if nom_recette else "Nom non trouvé"

    # Recherche du type de recette
    type_recette_elem = soup.select_one('.rd-bar-ico .rdbi-item .rdbii-val')
    type_recette = type_recette_elem.text.strip() if type_recette_elem else "Type non spécifié"

    # Extraction des informations générales
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

    # Extraction des calories
    calories = info_dict.get("Calories", "Non spécifié")

    # Extraction de l'image principale
    img_elem = soup.select_one('.carousel-item.active img')
    img_url = img_elem['src'] if img_elem else "Image non trouvée"
    if img_url.startswith("/"):
        img_url = "https://www.ptitchef.com" + img_url

    # Définir le mode manuellement (exemple)
    mode = "Spécial Dessert"

    # Stocker les données dans un dictionnaire
    recette = {
        "Mode": mode,
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

    # Afficher les résultats
    print("\n=== Résultats extraits ===")
    for key, value in recette.items():
        print(f"{key} : {value}")

    # Sauvegarde des résultats dans un fichier CSV
    output_csv = "recette_unique.csv"
    with open(output_csv, 'w', newline='', encoding='utf-8') as csvfile:
        fieldnames = recette.keys()
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerow(recette)

    print(f"\nExtraction terminée ! La recette a été enregistrée dans {output_csv}")
