import pandas as pd

# Charger le fichier CSV
file_path = "recettes.csv"  # Vérifie que le fichier est bien présent
df = pd.read_csv(file_path, encoding="utf-8")

# Afficher la dimension du fichier
print("📌 Dimensions du fichier (lignes, colonnes) :", df.shape)

# Afficher les 5 premières lignes
print("\n📋 Aperçu des 5 premières lignes :")
print(df.head())


