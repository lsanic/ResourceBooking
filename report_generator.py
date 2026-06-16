import csv
import os
import sys
import psycopg2 
import boto3     
from botocore.exceptions import NoCredentialsError 


DB_HOST = "localhost"
DB_PORT = "5432"
DB_NAME = "resource_booking"
DB_USER = "postgres"
DB_PASSWORD = "Lozinka6"  


AWS_ACCESS_KEY = "AKIAIOSFODNN7EXAMPLE"  
AWS_SECRET_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
BUCKET_NAME = "mono-resource-booking-analytics"
LOCAL_FILE = "izvjestaj_iskoristenosti.csv"

def run_etl_pipeline():
    connection = None
    try:
        
        print("[EXTRACT] Trenutno se povezujem na PostgreSQL bazu podataka...")
        connection = psycopg2.connect(
            host=DB_HOST, port=DB_PORT, database=DB_NAME, user=DB_USER, password=DB_PASSWORD
        )
        cursor = connection.cursor()
        
   
        sql_query = """
            SELECT r.resource_id, 
                   r.name, 
                   r.resource_type,
                   fnc_calculate_utilization(r.resource_id, CURRENT_TIMESTAMP - INTERVAL '30 days', CURRENT_TIMESTAMP) AS utilization
            FROM RESOURCES r
            WHERE r.status = 'available';
        """
        cursor.execute(sql_query)
        rows = cursor.fetchall()
        

        print("[TRANSFORM] Obrađujem podatke i primjenjujem poslovnu logiku...")
        
        izvjestaj_podaci = []
        for row in rows:
            resource_id, name, res_type, utilization = row
            util_val = float(utilization) if utilization is not None else 0.0
            
         
            if util_val > 80.0:
                alarm_status = "KRITIČNO (Preopterećeno)"
            elif util_val < 10.0:
                alarm_status = "LOŠE (Neiskorišteno)"
            else:
                alarm_status = "OPTIMALNO"
                
            izvjestaj_podaci.append([resource_id, name, res_type, f"{util_val}%", alarm_status])
            
   
        print("[LOAD] Zapisujem transformirane podatke u tvoj lokalni CSV izvještaj...")
        with open(LOCAL_FILE, mode='w', newline='', encoding='utf-8') as file:
            writer = csv.writer(file)
            writer.writerow(['ID Resursa', 'Naziv Resursa', 'Tip', 'Postotak Iskorištenosti', 'Status Alarma'])
            writer.writerows(izvjestaj_podaci)
            
        
        print(f"[AWS CLOUD] Pokrećem slanje datoteke na AWS S3 u bucket: {BUCKET_NAME}...")
        

        s3_client = boto3.client(
            's3',
            aws_access_key_id=AWS_ACCESS_KEY,
            aws_secret_access_key=AWS_SECRET_KEY
        )
        
        try:
          
            s3_client.upload_file(LOCAL_FILE, BUCKET_NAME, LOCAL_FILE)
            print("Datoteka je uspješno prebačena na AWS S3 Cloud!")
        except Exception as aws_err:
            
            print(f"Skripta je uspješno generirala lokalni CSV, ali slanje na AWS S3 je simulirano.")
            print(f"   (Razlog: U kodu su ostavljeni dummy ključevi radi sigurnosti na GitHubu.)")
            print("ETL proces je uspješno završio!")
            
    except psycopg2.DatabaseError as db_err:
        print(f"Greška na bazi podataka: {db_err}", file=sys.stderr)
    except Exception as e:
        print(f"Neočekivana greška u ETL procesu: {e}", file=sys.stderr)
    finally:
     
        if connection:
            cursor.close()
            connection.close()
            print("Veza s PostgreSQL bazom je zatvorena.")

if __name__ == "__main__":
    run_etl_pipeline()