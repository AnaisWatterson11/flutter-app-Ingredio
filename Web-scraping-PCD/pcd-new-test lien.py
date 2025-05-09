import time
import requests
from bs4 import BeautifulSoup

# URL de la recette à scrapper
url = "https://www.ptitchef.com/recettes/autre/glace-aux-fraises-tagada-fid-98404"

# Envoyer la requête HTTP pour obtenir le contenu de la page
response = requests.get(url)
if response.status_code != 200:
    print(f"Erreur {response.status_code} pour {url}")
else:
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
        calories = calories_general
    elif calories_specifique_elem and "Kcal" in calories_specifique_elem.text:
        calories = calories_specifique_elem.text.strip()
    else:
        calories = "Non spécifié"

    # Extraction de l'image principale
    img_elem = soup.select_one('.carousel-item.active img')
    img_url = img_elem['src'] if img_elem else "Image non trouvée"
    if img_url.startswith("/"):
        img_url = "https://www.ptitchef.com" + img_url  # Corriger l'URL relative

    # Affichage des informations extraites
    print(f"Nom de la recette : {nom_recette}")
    print(f"Calories : {calories}")
    print(f"Coût total : {cout_total}")
    print(f"Coût par part : {cout_par_part}")
    print(f"Temps de préparation : {temps_prep}")
    print(f"Temps de cuisson : {temps_cuisson}")
    print(f"Ingrédients : {', '.join(ingredients)}")
    print(f"Étapes de préparation : {' | '.join(etapes)}")
    print(f"Image : {img_url}")
    print(f"URL : {url}")

    # Attendre 1 seconde entre chaque requête (si vous décidez d'agrandir votre scraping plus tard)
    time.sleep(1)
