import requests
from bs4 import BeautifulSoup

# URL de la recette
url = "https://www.ptitchef.com/recettes/aperitif/mini-croissants-pizza-au-jambon-et-fromage-fid-1563914"

# Récupération de la page HTML
response = requests.get(url)
if response.status_code != 200:
    print(f"Erreur {response.status_code} lors de la récupération de la page")
    exit()

soup = BeautifulSoup(response.text, 'html.parser')

# 📌 Extraction du nom de la recette
nom_recette = soup.find('h1', class_='title animated fadeInDown')
nom_recette = nom_recette.text.strip() if nom_recette else "Nom non trouvé"

# 📋 Extraction des informations générales
info_dict = {}
info_items = soup.select('.rd-bar-ico .rdbi-item')

for item in info_items:
    key = item.get('title', '').split(":")[0]  # Extrait le titre
    value = item.find(class_='rdbii-val')
    if key and value:
        info_dict[key] = value.text.strip()

# 🍽 Extraction des ingrédients
ingredients = [li.get_text(strip=True) for li in soup.select('.ingredients-ul li label')]

# 💰 Extraction du coût estimé
cout_total = soup.select_one('.e-cost-total')
cout_par_part = soup.select_one('.e-cost-serving')

cout_total = cout_total.text.strip() if cout_total else "Non spécifié"
cout_par_part = cout_par_part.text.strip() if cout_par_part else "Non spécifié"

# ⏳ Extraction des temps de préparation et cuisson
temps_prep = soup.select_one('.rd-times .rdt-item:nth-of-type(1)')
temps_cuisson = soup.select_one('.rd-times .rdt-item:nth-of-type(2)')

temps_prep = temps_prep.get_text(strip=True).replace("Préparation", "").strip() if temps_prep else "Non spécifié"
temps_cuisson = temps_cuisson.get_text(strip=True).replace("Cuisson", "").strip() if temps_cuisson else "Non spécifié"

# 📜 Extraction des étapes de préparation
etapes = [li.get_text(" ", strip=True) for li in soup.select('.rd-steps li')]

# 🔥 Extraction des calories (priorité à la valeur disponible)
calories_elem = soup.select_one('.nutrition-value') or soup.select_one('.nm-calories span:last-child')
calories = calories_elem.text.strip() if calories_elem else None

# Si les calories sont absentes ici, chercher dans `info_dict`
if not calories or calories == "Non spécifié":
    for key in ["Calories", "Valeur énergétique"]:
        if key in info_dict:
            calories = info_dict[key]
            break  # On prend la première valeur trouvée

# Si toujours vide, alors "Non spécifié"
calories = calories + " Kcal" if calories and "Kcal" not in calories else "Non spécifié"

# 🖼 Extraction de l'image principale
img_elem = soup.select_one('.carousel-item.active img')
if img_elem:
    img_url = img_elem['src']
    if img_url.startswith("/"):
        img_url = "https://www.ptitchef.com" + img_url  # Corriger l'URL relative
else:
    img_url = "Image non trouvée"

# 🎯 Affichage des résultats
print(f"📌 Nom de la recette : {nom_recette}\n")

print("📋 Informations générales :")
for key, value in info_dict.items():
    print(f"- {key} : {value}")

print("\n🍽 Ingrédients :")
for ingr in ingredients:
    print(f"- {ingr}")

print(f"\n💰 Coût estimé : {cout_total} ({cout_par_part})")
print(f"⏳ Temps de préparation : {temps_prep}")
print(f"🔥 Temps de cuisson : {temps_cuisson}")

print(f"\n🔥 Calories : {calories} par portion\n")

print("📜 Étapes de préparation :")
for i, etape in enumerate(etapes, 1):
    print(f"{i}. {etape}")

print(f"\n🖼 Image de la recette : {img_url}")


