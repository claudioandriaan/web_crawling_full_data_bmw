#!/usr/bin/python
# -*- coding: utf-8 -*-
import json
import sys
import re
import html  # Import the html module for unescape
from html.parser import HTMLParser  # Import HTMLParser directly from html.parser

jsonFile = str(sys.argv[1])

html_parser = HTMLParser  # Create an instance of HTMLParser directly

# Function definition is here
def clean_html(raw_html):
    cleanr = re.compile('<.*?>')
    cleantext = re.sub(cleanr, '', raw_html)
    return re.sub(r'\s+', ' ', cleantext).strip()

def cleanSQL(str_option):
    result = html.unescape(str(str_option))
    result = clean_html(result)
    result = result.replace('\t', ' ').replace('\r', ' ').replace('\n', ' ').replace("\"", " ").replace("\',", ",").replace("\\", "")
    return re.sub(r'\s+', ' ', result).strip()


def parsing_data(items):
    val = {}
    c = 0

    for item in items:
        # init array value
        for i in range(max_i):
            val[title[i], c] = ""

        # collection values
        for key in item.keys():
            if key == "advert_id" and item["advert_id"] is not None:
                val["ID_CLIENT", c] = item["advert_id"]
                val["ANNONCE_LINK", c] = "https://usedcars.bmw.co.uk/vehicle/" + str(item["advert_id"])
            if key == "cash_price": 
                val["PRIX", c] = item["cash_price"]["value"]
            if key == "derivative" and item["derivative"] is not None:
                val["NOM", c] = item["derivative"]
            if key == "fuel" and item["fuel"]:
                val["CARBURANT", c] = item["fuel"] 
            if key == "transmission" and item["transmission"] is not None:
               	val["TRANSMISSION", c] = item["transmission"]
            if key == "vin" and item["vin"] is not None: 
                val["VIN", c] = item["vin"]
            if key == "mileage" and item["mileage"] is not None:
               	val["KM", c] = item["mileage"]
        if key == "registration": 
            val["ANNEE", c] = item["date"]
        
        
			       
        c = c + 1

    # print out fields to extract.tab
    max_c = c
    c = 0

    for c in range(max_c):
        if val["ID_CLIENT", c] != "":
            string = ""
            for i in range(max_i):
                string = string + cleanSQL(val[title[i], c]) + "\t"

            string = string + jsonFile + "\t"
            print(string)

# Define List Fields which will be identical naming and order with file list_table.awk
title = []
title.append("ID_CLIENT")
title.append("ANNONCE_LINK")
title.append("PRIX")
title.append("NOM")
title.append("CARBURANT")
title.append("TRANSMISSION")
title.append("VIN")
title.append("KM")
title.append("ANNEE")
title.append("KM_ORIGINAL")
title.append("BOITE")
title.append("LITRE_ORIGINAL")
title.append("PUISSANCE")


max_i = len(title)

with open(jsonFile) as fileData:
    content = fileData.read()

    # collect json text in file HTML
    try:
        data_json = content

    except IndexError:
        print("Error: Unable to extract data from the content. Check the structure of the JSON file.")
        # You might want to handle this error in an appropriate way for your application.

    # converting json string to object
    data = json.loads(data_json)

    # getting list ads
    items = data["results"]
    parsing_data(items)
