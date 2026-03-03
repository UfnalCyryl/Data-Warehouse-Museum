import pandas as pd
import random
from datetime import datetime, timedelta
import os

# ------------------ CONFIG ------------------
NUM_ARTISTS = 100
NUM_PATRONS = 1000
NUM_ARTWORKS = 1000
NUM_DONATIONS = 500
NUM_BORROWED = 50
NUM_PURPOSES = 8
NUM_STATUSES = 5
NUM_INSTITUTIONS = 15
START_DATE = datetime(2000, 1, 1)

# ------------------ Helper Functions ------------------
def generate_unique_numbers(n, length=11):
    nums = set()
    while len(nums) < n:
        nums.add(str(random.randint(10**(length-1), 10**length - 1)))
    return list(nums)

def random_date(start, end_days):
    return start + timedelta(days=random.randint(0, end_days))

# ------------------ Artists ------------------
artist_pesels = generate_unique_numbers(NUM_ARTISTS)
artist_names = ["Leonardo", "Pablo", "Vincent", "Frida", "Salvador", "Claude", "Georgia", "Michelangelo", "Rembrandt", "Andy"]
artist_surnames = ["da Vinci", "Picasso", "van Gogh", "Kahlo", "Dali", "Monet", "OKeeffe", "Buonarroti", "van Rijn", "Warhol"]

df_artists = pd.DataFrame([{
    "PESEL": artist_pesels[i],
    "Birth_year": (birth := random.randint(1500, 1990)),
    "Death_year": (death := (birth + random.randint(20, 80))),
    "Nationality": random.choice(["Polish", "French", "German", "American", "Italian"]),
    "Name": random.choice(artist_names),
    "Surname": random.choice(artist_surnames)
} for i in range(NUM_ARTISTS)])

# ------------------ Patrons ------------------
patron_pesels = generate_unique_numbers(NUM_PATRONS)
first_names = ["James", "Mary", "John", "Patricia", "Robert"]
surnames = ["Smith", "Johnson", "Williams", "Jones", "Brown"]

df_patrons = pd.DataFrame([{
    "PESEL": patron_pesels[i],
    "Type": random.choice(["Individual", "Organization"]),
    "Phone_number": str(random.randint(500000000, 899999999)),
    "Address": f"{random.randint(1, 999)} {random.choice(['Main', 'Oak'])} {random.choice(['St', 'Ave'])}",
    "Membership_status": random.choice(["Active", "Expired", "None"]),
    "Membership_level": random.choice(["Platinum", "Gold", "Silver", "Bronze"]),
    "Date_joined": (joined := random_date(START_DATE, 8000)).strftime('%Y-%m-%d'),
    "Name": (fn := random.choice(first_names)),
    "Surname": (sn := random.choice(surnames)),
    "Country": random.choice(["USA", "Canada"]),
    "City": random.choice(["New York", "Toronto"]),
    "District": random.choice(["Downtown", "Old Town"]),
    "Street": f"{random.choice(['Maple', 'Pine'])} {random.choice(['St', 'Ave'])}"
} for i in range(NUM_PATRONS)])

# ------------------ Artworks ------------------
df_artworks = pd.DataFrame([{
    "ARTWORK_AUTHENTICITY_CERT_NUM": f"CERT{i:05d}",
    "Title": f"Artwork Title {i}",
    "Year_created": random.randint(1900, 2020),
    "Type": random.choice(["Painting", "Sculpture"]),
    "Medium": random.choice(["Oil", "Marble"]),
    "Category_of_size": random.choice(["Small", "Medium", "Big"]),
    "Permanent": random.choice([0, 1]),
    "Artist_PESEL": random.choice(df_artists["PESEL"])
} for i in range(NUM_ARTWORKS)])

# ------------------ Institutions ------------------
institution_names = [f"Institution {i}" for i in range(NUM_INSTITUTIONS)]
df_institutions = pd.DataFrame([{
    "Name": name,
    "Prestige": round(random.uniform(1, 10), 1),
    "Country": "USA",
    "City": "New York",
    "District": "Museum District",
    "Street": f"{random.randint(1, 999)} Museum Ave"
} for name in institution_names])

# ------------------ Junk Donation Purposes ------------------
purposes = ["Restoration", "Acquisition", "Conservation", "Exhibition", "Education", "Research", "Improvement", "Events"]
df_junk_donation = pd.DataFrame({"Purpose": purposes[:NUM_PURPOSES]})

# ------------------ Junk Borrowing Statuses ------------------
statuses = ["Ongoing", "Completed", "In Transit", "Returned", "Lost"]
df_junk_borrowing = pd.DataFrame([{
    "Status": s,
    "Borrowed": int(random.random() > 0.5),
    "Lent": int(random.random() > 0.5),
    "Owned": int(random.random() > 0.5)
} for s in statuses[:NUM_STATUSES]])

# ------------------ Donations (Fact Table) ------------------
df_donations = pd.DataFrame([{
    "INVOICE_NUMBER": f"INV{i:05d}",
    "Amount": round(random.uniform(100, 5000), 2),
    "Date_of_donation": (don_date := random_date(START_DATE, 8000)).strftime('%Y-%m-%d'),
    "Purpose": random.choice(df_junk_donation["Purpose"]),
    "Artwork_ID": random.choice(df_artworks["ARTWORK_AUTHENTICITY_CERT_NUM"]),
    "Patron_PESEL": random.choice(df_patrons["PESEL"])
} for i in range(NUM_DONATIONS)])

# ------------------ Borrowed or Lent (Fact Table) ------------------
df_borrowed_or_lent = pd.DataFrame([{
    "Borrowing_ID": i + 1,
    "Artwork_ID": random.choice(df_artworks["ARTWORK_AUTHENTICITY_CERT_NUM"]),
    "Institution": random.choice(df_institutions["Name"]),
    "Start_date": (sd := random_date(START_DATE, 8000)).strftime('%Y-%m-%d'),
    "End_date": "" if (status := random.choice(statuses)) == "Ongoing" else random_date(sd, 1000).strftime('%Y-%m-%d'),
    "Status": status,
    "Borrowed": int(random.random() > 0.5),
    "Lent": int(random.random() > 0.5),
    "Owned": int(random.random() > 0.5)
} for i in range(NUM_BORROWED)])

# ------------------ Export All CSVs ------------------
os.makedirs("output_csv", exist_ok=True)

df_artists.to_csv("output_csv/Artist.csv", index=False)
df_patrons.to_csv("output_csv/Patron.csv", index=False)
df_artworks.to_csv("output_csv/Artwork.csv", index=False)
df_institutions.to_csv("output_csv/Institutions.csv", index=False)
df_junk_donation.to_csv("output_csv/Junk_Donation.csv", index=False)
df_junk_borrowing.to_csv("output_csv/Junk_Borrowing.csv", index=False)
df_donations.to_csv("output_csv/Donations.csv", index=False)
df_borrowed_or_lent.to_csv("output_csv/Borrowed_orLent.csv", index=False)

print("✅ All consistent CSVs generated and saved in the 'output_csv' folder.")
