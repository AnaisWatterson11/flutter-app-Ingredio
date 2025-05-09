import pandas as pd

# Lire le fichier CSV contenant les liens et les catégories
df = pd.read_csv("recipe_links_filtered.csv")

# Dictionnaire pour suivre les liens qui appartiennent à plusieurs catégories
multi_category_links = {}

# Vérifier chaque ligne pour les liens qui apparaissent dans plusieurs catégories
for index, row in df.iterrows():
    link = row["Recipe_Link"]
    categories = row["Categories"].split(", ")  # Découper les catégories si plusieurs
    
    # Vérifier s'il appartient à plusieurs catégories
    if link not in multi_category_links:
        multi_category_links[link] = categories
    else:
        # Ajouter les nouvelles catégories s'il appartient à plusieurs
        multi_category_links[link] = list(set(multi_category_links[link] + categories))

# Compter le nombre de liens qui appartiennent à plusieurs catégories
multi_category_count = 0
for link, categories in multi_category_links.items():
    if len(categories) > 1:
        multi_category_count += 1
        print(f"{link} -> {', '.join(categories)}")

# Afficher le nombre de liens qui appartiennent à plusieurs catégories
print(f"\n Nombre de liens qui appartiennent à plusieurs catégories : {multi_category_count}")
