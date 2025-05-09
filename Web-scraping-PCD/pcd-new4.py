import pandas as pd
import requests

# Lire le fichier CSV contenant les liens et les catégories
df = pd.read_csv("recipe_links_filtered.csv")

# Liste pour suivre les résultats des liens
url_status = []

# Fonction pour vérifier si une URL est valide
def check_url_status(url):
    try:
        response = requests.get(url)
        if response.status_code == 200:
            return "OK"
        elif response.status_code == 403:
            return "Forbidden (403)"
        elif response.status_code == 404:
            return "Not Found (404)"
        else:
            return f"Error {response.status_code}"
    except requests.exceptions.RequestException as e:
        return f"Request Error: {e}"

# Compteurs pour les liens valides et non valides
valid_links = 0
invalid_links = 0

# Vérifier chaque ligne du DataFrame pour les liens
for index, row in df.iterrows():
    link = row["Recipe_Link"]
    status = check_url_status(link)
    
    # Mettre à jour les compteurs
    if status == "OK":
        valid_links += 1
    else:
        invalid_links += 1
    
    # Ajouter l'URL et son statut à la liste
    url_status.append({
        "Recipe_Link": link,
        "Status": status
    })

# Convertir les résultats dans un DataFrame
status_df = pd.DataFrame(url_status)

# Sauvegarder les résultats dans un fichier CSV
status_df.to_csv("url_status_results.csv", index=False)

# Afficher les résultats
print("URL Status check completed! Results are saved in 'url_status_results.csv'.")
print(status_df.head())  # Afficher les 5 premiers résultats

# Afficher la dimension du fichier original et le nombre de liens valides et non valides
print(f"\nDimension du fichier original : {df.shape[0]} lignes")
print(f"Nombre de liens valides : {valid_links}")
print(f"Nombre de liens non valides : {invalid_links}")
