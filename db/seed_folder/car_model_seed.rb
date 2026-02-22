# ============================================
# MASSIVE CAR MODELS DATA - WITH BODY TYPE & PRODUCTION START DATE
# ============================================

models_data = {

  "Ford" => [
    { name: "F-150",      body_type: :truck,       year: 1975 },
    { name: "F-250",      body_type: :truck,       year: 1953 },
    { name: "F-350",      body_type: :truck,       year: 1953 },
    { name: "Mustang",    body_type: :coupe,       year: 1964 },
    { name: "Explorer",   body_type: :suv,         year: 1991 },
    { name: "Escape",     body_type: :suv,         year: 2001 },
    { name: "Edge",       body_type: :suv,         year: 2007 },
    { name: "Bronco",     body_type: :suv,         year: 1966 },
    { name: "Expedition", body_type: :suv,         year: 1997 },
    { name: "Maverick",   body_type: :truck,       year: 2022 },
    { name: "Ranger",     body_type: :truck,       year: 1983 }
  ],

  "Chevrolet" => [
    { name: "Silverado",  body_type: :truck,       year: 1999 },
    { name: "Colorado",   body_type: :truck,       year: 2004 },
    { name: "Malibu",     body_type: :sedan,       year: 1964 },
    { name: "Camaro",     body_type: :coupe,       year: 1967 },
    { name: "Corvette",   body_type: :sports,      year: 1953 },
    { name: "Tahoe",      body_type: :suv,         year: 1995 },
    { name: "Suburban",   body_type: :suv,         year: 1935 },
    { name: "Equinox",    body_type: :suv,         year: 2005 },
    { name: "Traverse",   body_type: :suv,         year: 2009 },
    { name: "Blazer",     body_type: :suv,         year: 1969 },
    { name: "Spark",      body_type: :hatchback,   year: 2013 }
  ],

  "GMC" => [
    { name: "Sierra",     body_type: :truck,       year: 1999 },
    { name: "Canyon",     body_type: :truck,       year: 2004 },
    { name: "Yukon",      body_type: :suv,         year: 1992 },
    { name: "Acadia",     body_type: :suv,         year: 2007 },
    { name: "Terrain",    body_type: :suv,         year: 2010 },
    { name: "Savana",     body_type: :van,         year: 1996 },
    { name: "Hummer EV",  body_type: :electric,    year: 2021 },
    { name: "SierraHD",   body_type: :truck,       year: 2001 },
    { name: "YukonXL",    body_type: :suv,         year: 2000 },
    { name: "Jimmy",      body_type: :suv,         year: 1970 },
    { name: "Envoy",      body_type: :suv,         year: 1998 }
  ],

  "Cadillac" => [
    { name: "Escalade",   body_type: :suv,         year: 1999 },
    { name: "XT4",        body_type: :suv,         year: 2019 },
    { name: "XT5",        body_type: :suv,         year: 2017 },
    { name: "XT6",        body_type: :suv,         year: 2020 },
    { name: "CT4",        body_type: :sedan,       year: 2020 },
    { name: "CT5",        body_type: :sedan,       year: 2020 },
    { name: "CTS",        body_type: :sedan,       year: 2003 },
    { name: "ATS",        body_type: :sedan,       year: 2013 },
    { name: "XTS",        body_type: :sedan,       year: 2013 },
    { name: "Eldorado",   body_type: :coupe,       year: 1953 },
    { name: "DeVille",    body_type: :sedan,       year: 1959 }
  ],

  "Tesla" => [
    { name: "Model S",    body_type: :electric,    year: 2012 },
    { name: "Model 3",    body_type: :electric,    year: 2017 },
    { name: "Model X",    body_type: :electric,    year: 2015 },
    { name: "Model Y",    body_type: :electric,    year: 2020 },
    { name: "Cybertruck", body_type: :electric,    year: 2023 },
    { name: "Roadster",   body_type: :electric,    year: 2008 },
    { name: "Semi",       body_type: :electric,    year: 2022 },
    { name: "Model 2",    body_type: :electric,    year: 2025 },
    { name: "Model Z",    body_type: :electric,    year: 2025 },
    { name: "Model Q",    body_type: :electric,    year: 2025 }
  ],

  "Dodge" => [
    { name: "Charger",    body_type: :sedan,       year: 1966 },
    { name: "Challenger", body_type: :coupe,       year: 1970 },
    { name: "Durango",    body_type: :suv,         year: 1998 },
    { name: "Journey",    body_type: :suv,         year: 2009 },
    { name: "Dakota",     body_type: :truck,       year: 1987 },
    { name: "Ram",        body_type: :truck,       year: 1981 },
    { name: "Nitro",      body_type: :suv,         year: 2007 },
    { name: "Viper",      body_type: :sports,      year: 1992 },
    { name: "Avenger",    body_type: :sedan,       year: 1995 },
    { name: "Magnum",     body_type: :wagon,       year: 2005 },
    { name: "Dart",       body_type: :sedan,       year: 1960 }
  ],

  "Chrysler" => [
    { name: "300",            body_type: :sedan,       year: 2005 },
    { name: "Pacifica",       body_type: :van,         year: 2017 },
    { name: "Voyager",        body_type: :van,         year: 1984 },
    { name: "Aspen",          body_type: :suv,         year: 2007 },
    { name: "Sebring",        body_type: :sedan,       year: 1995 },
    { name: "Town & Country", body_type: :van,         year: 1990 },
    { name: "Crossfire",      body_type: :coupe,       year: 2004 },
    { name: "PT Cruiser",     body_type: :hatchback,   year: 2001 },
    { name: "Concorde",       body_type: :sedan,       year: 1993 },
    { name: "Imperial",       body_type: :sedan,       year: 1955 }
  ],

  "Jeep" => [
    { name: "Wrangler",       body_type: :suv,         year: 1987 },
    { name: "Cherokee",       body_type: :suv,         year: 1974 },
    { name: "Grand-Cherokee", body_type: :suv,         year: 1993 },
    { name: "Compass",        body_type: :suv,         year: 2007 },
    { name: "Renegade",       body_type: :suv,         year: 2015 },
    { name: "Gladiator",      body_type: :truck,       year: 2020 },
    { name: "Wagoneer",       body_type: :suv,         year: 1963 },
    { name: "Patriot",        body_type: :suv,         year: 2007 },
    { name: "Liberty",        body_type: :suv,         year: 2002 },
    { name: "Commander",      body_type: :suv,         year: 2006 }
  ],

  "Lincoln" => [
    { name: "Navigator",   body_type: :suv,         year: 1998 },
    { name: "Aviator",     body_type: :suv,         year: 2003 },
    { name: "Corsair",     body_type: :suv,         year: 2020 },
    { name: "Nautilus",    body_type: :suv,         year: 2019 },
    { name: "MKZ",         body_type: :sedan,       year: 2007 },
    { name: "MKX",         body_type: :suv,         year: 2007 },
    { name: "Continental", body_type: :sedan,       year: 1940 },
    { name: "Town-Car",    body_type: :sedan,       year: 1981 },
    { name: "LS",          body_type: :sedan,       year: 2000 },
    { name: "Zephyr",      body_type: :sedan,       year: 2006 }
  ],

  "Ram" => [
    { name: "1500",        body_type: :truck,       year: 2009 },
    { name: "2500",        body_type: :truck,       year: 2009 },
    { name: "3500",        body_type: :truck,       year: 2009 },
    { name: "ProMaster",   body_type: :van,         year: 2014 },
    { name: "Rebel",       body_type: :truck,       year: 2015 },
    { name: "TRX",         body_type: :truck,       year: 2021 },
    { name: "Classic",     body_type: :truck,       year: 2019 },
    { name: "Limited",     body_type: :truck,       year: 2014 },
    { name: "Tradesman",   body_type: :truck,       year: 2009 },
    { name: "BigHorn",     body_type: :truck,       year: 2009 },
    { name: "Laramie",     body_type: :truck,       year: 2009 }
  ],

  "Buick" => [
    { name: "Encore",      body_type: :suv,         year: 2013 },
    { name: "Enclave",     body_type: :suv,         year: 2008 },
    { name: "Envision",    body_type: :suv,         year: 2016 },
    { name: "LaCrosse",    body_type: :sedan,       year: 2005 },
    { name: "Regal",       body_type: :sedan,       year: 1973 },
    { name: "Verano",      body_type: :sedan,       year: 2012 },
    { name: "Cascada",     body_type: :convertible, year: 2016 },
    { name: "Century",     body_type: :sedan,       year: 1936 },
    { name: "LeSabre",     body_type: :sedan,       year: 1959 },
    { name: "ParkAvenue",  body_type: :sedan,       year: 1991 },
    { name: "Roadmaster",  body_type: :wagon,       year: 1991 }
  ],

  # ---- JAPANESE ----

  "Toyota" => [
    { name: "Camry",       body_type: :sedan,       year: 1982 },
    { name: "Corolla",     body_type: :sedan,       year: 1966 },
    { name: "RAV4",        body_type: :suv,         year: 1994 },
    { name: "Highlander",  body_type: :suv,         year: 2001 },
    { name: "Tacoma",      body_type: :truck,       year: 1995 },
    { name: "Tundra",      body_type: :truck,       year: 2000 },
    { name: "Supra",       body_type: :sports,      year: 1978 },
    { name: "Prius",       body_type: :hatchback,   year: 1997 },
    { name: "Avalon",      body_type: :sedan,       year: 1994 },
    { name: "Sequoia",     body_type: :suv,         year: 2001 },
    { name: "Venza",       body_type: :suv,         year: 2009 }
  ],

  "Honda" => [
    { name: "Civic",       body_type: :sedan,       year: 1972 },
    { name: "Accord",      body_type: :sedan,       year: 1976 },
    { name: "CR-V",        body_type: :suv,         year: 1995 },
    { name: "Pilot",       body_type: :suv,         year: 2003 },
    { name: "HR-V",        body_type: :suv,         year: 2015 },
    { name: "Odyssey",     body_type: :van,         year: 1994 },
    { name: "Ridgeline",   body_type: :truck,       year: 2006 },
    { name: "Fit",         body_type: :hatchback,   year: 2001 },
    { name: "Passport",    body_type: :suv,         year: 1993 },
    { name: "Insight",     body_type: :sedan,       year: 1999 },
    { name: "Prelude",     body_type: :coupe,       year: 1978 }
  ],

  "Nissan" => [
    { name: "Altima",      body_type: :sedan,       year: 1993 },
    { name: "Sentra",      body_type: :sedan,       year: 1982 },
    { name: "Rogue",       body_type: :suv,         year: 2008 },
    { name: "Pathfinder",  body_type: :suv,         year: 1987 },
    { name: "Frontier",    body_type: :truck,       year: 1998 },
    { name: "Titan",       body_type: :truck,       year: 2004 },
    { name: "Versa",       body_type: :sedan,       year: 2007 },
    { name: "Murano",      body_type: :suv,         year: 2003 },
    { name: "Armada",      body_type: :suv,         year: 2004 },
    { name: "GT-R",        body_type: :sports,      year: 2007 },
    { name: "Maxima",      body_type: :sedan,       year: 1981 }
  ],

  "Mazda" => [
    { name: "Mazda3",      body_type: :sedan,       year: 2004 },
    { name: "Mazda6",      body_type: :sedan,       year: 2002 },
    { name: "CX-3",        body_type: :suv,         year: 2015 },
    { name: "CX-5",        body_type: :suv,         year: 2012 },
    { name: "CX-9",        body_type: :suv,         year: 2007 },
    { name: "MX-5",        body_type: :convertible, year: 1989 },
    { name: "CX-30",       body_type: :suv,         year: 2019 },
    { name: "CX-50",       body_type: :suv,         year: 2022 },
    { name: "RX-8",        body_type: :coupe,       year: 2003 },
    { name: "Tribute",     body_type: :suv,         year: 2001 },
    { name: "B-Series",    body_type: :truck,       year: 1961 }
  ],

  "Subaru" => [
    { name: "Outback",     body_type: :wagon,       year: 1994 },
    { name: "Forester",    body_type: :suv,         year: 1997 },
    { name: "Crosstrek",   body_type: :suv,         year: 2012 },
    { name: "Impreza",     body_type: :sedan,       year: 1992 },
    { name: "WRX",         body_type: :sedan,       year: 1992 },
    { name: "Legacy",      body_type: :sedan,       year: 1989 },
    { name: "Ascent",      body_type: :suv,         year: 2019 },
    { name: "BRZ",         body_type: :coupe,       year: 2012 },
    { name: "Baja",        body_type: :truck,       year: 2003 },
    { name: "Tribeca",     body_type: :suv,         year: 2006 },
    { name: "XV",          body_type: :suv,         year: 2012 }
  ],

  "Mitsubishi" => [
    { name: "Outlander",   body_type: :suv,         year: 2001 },
    { name: "Eclipse",     body_type: :coupe,       year: 1989 },
    { name: "Mirage",      body_type: :hatchback,   year: 1978 },
    { name: "Lancer",      body_type: :sedan,       year: 1973 },
    { name: "Galant",      body_type: :sedan,       year: 1969 },
    { name: "Montero",     body_type: :suv,         year: 1982 },
    { name: "Pajero",      body_type: :suv,         year: 1982 },
    { name: "Raider",      body_type: :truck,       year: 2006 },
    { name: "Endeavor",    body_type: :suv,         year: 2004 },
    { name: "Diamante",    body_type: :sedan,       year: 1990 }
  ],

  "Lexus" => [
    { name: "RX",          body_type: :suv,         year: 1998 },
    { name: "NX",          body_type: :suv,         year: 2015 },
    { name: "ES",          body_type: :sedan,       year: 1989 },
    { name: "IS",          body_type: :sedan,       year: 1999 },
    { name: "GX",          body_type: :suv,         year: 2002 },
    { name: "LX",          body_type: :suv,         year: 1996 },
    { name: "LC",          body_type: :coupe,       year: 2017 },
    { name: "RC",          body_type: :coupe,       year: 2015 },
    { name: "UX",          body_type: :suv,         year: 2019 },
    { name: "GS",          body_type: :sedan,       year: 1993 },
    { name: "LS",          body_type: :sedan,       year: 1989 }
  ],

  "Infiniti" => [
    { name: "Q50",         body_type: :sedan,       year: 2014 },
    { name: "Q60",         body_type: :coupe,       year: 2017 },
    { name: "QX50",        body_type: :suv,         year: 2008 },
    { name: "QX60",        body_type: :suv,         year: 2013 },
    { name: "QX80",        body_type: :suv,         year: 2004 },
    { name: "FX35",        body_type: :suv,         year: 2003 },
    { name: "FX45",        body_type: :suv,         year: 2003 },
    { name: "G35",         body_type: :sedan,       year: 2003 },
    { name: "G37",         body_type: :sedan,       year: 2008 },
    { name: "M35",         body_type: :sedan,       year: 2006 }
  ],

  "Acura" => [
    { name: "TLX",         body_type: :sedan,       year: 2015 },
    { name: "ILX",         body_type: :sedan,       year: 2013 },
    { name: "MDX",         body_type: :suv,         year: 2001 },
    { name: "RDX",         body_type: :suv,         year: 2007 },
    { name: "NSX",         body_type: :sports,      year: 1990 },
    { name: "RL",          body_type: :sedan,       year: 1996 },
    { name: "TSX",         body_type: :sedan,       year: 2004 },
    { name: "CL",          body_type: :coupe,       year: 1997 },
    { name: "RSX",         body_type: :coupe,       year: 2002 },
    { name: "Integra",     body_type: :sedan,       year: 1986 },
    { name: "ZDX",         body_type: :suv,         year: 2010 }
  ],

  # ---- EUROPEAN ----

  "BMW" => [
    { name: "3 Series",    body_type: :sedan,       year: 1975 },
    { name: "5 Series",    body_type: :sedan,       year: 1972 },
    { name: "7 Series",    body_type: :sedan,       year: 1977 },
    { name: "X1",          body_type: :suv,         year: 2009 },
    { name: "X3",          body_type: :suv,         year: 2003 },
    { name: "X5",          body_type: :suv,         year: 1999 },
    { name: "X7",          body_type: :suv,         year: 2019 },
    { name: "M3",          body_type: :sports,      year: 1986 },
    { name: "M5",          body_type: :sports,      year: 1985 },
    { name: "i4",          body_type: :electric,    year: 2021 },
    { name: "iX",          body_type: :electric,    year: 2022 }
  ],

  "Mercedes-Benz" => [
    { name: "C-Class",     body_type: :sedan,       year: 1993 },
    { name: "E-Class",     body_type: :sedan,       year: 1984 },
    { name: "S-Class",     body_type: :sedan,       year: 1972 },
    { name: "GLA",         body_type: :suv,         year: 2014 },
    { name: "GLC",         body_type: :suv,         year: 2016 },
    { name: "GLE",         body_type: :suv,         year: 2015 },
    { name: "GLS",         body_type: :suv,         year: 2013 },
    { name: "G-Class",     body_type: :suv,         year: 1979 },
    { name: "AMG GT",      body_type: :sports,      year: 2015 },
    { name: "CLA",         body_type: :sedan,       year: 2013 },
    { name: "EQE",         body_type: :electric,    year: 2022 }
  ],

  "Audi" => [
    { name: "A3",          body_type: :sedan,       year: 1996 },
    { name: "A4",          body_type: :sedan,       year: 1994 },
    { name: "A6",          body_type: :sedan,       year: 1994 },
    { name: "A8",          body_type: :sedan,       year: 1994 },
    { name: "Q3",          body_type: :suv,         year: 2011 },
    { name: "Q5",          body_type: :suv,         year: 2008 },
    { name: "Q7",          body_type: :suv,         year: 2006 },
    { name: "Q8",          body_type: :suv,         year: 2018 },
    { name: "TT",          body_type: :coupe,       year: 1998 },
    { name: "R8",          body_type: :sports,      year: 2006 },
    { name: "e-tron",      body_type: :electric,    year: 2019 }
  ],

  "Volkswagen" => [
    { name: "Jetta",       body_type: :sedan,       year: 1980 },
    { name: "Passat",      body_type: :sedan,       year: 1973 },
    { name: "Golf",        body_type: :hatchback,   year: 1974 },
    { name: "Tiguan",      body_type: :suv,         year: 2007 },
    { name: "Atlas",       body_type: :suv,         year: 2018 },
    { name: "Beetle",      body_type: :hatchback,   year: 1938 },
    { name: "Arteon",      body_type: :sedan,       year: 2017 },
    { name: "Taos",        body_type: :suv,         year: 2022 },
    { name: "ID4",         body_type: :electric,    year: 2021 },
    { name: "Touareg",     body_type: :suv,         year: 2003 },
    { name: "CC",          body_type: :sedan,       year: 2009 }
  ],

  "Porsche" => [
    { name: "911",         body_type: :sports,      year: 1963 },
    { name: "Cayenne",     body_type: :suv,         year: 2003 },
    { name: "Macan",       body_type: :suv,         year: 2014 },
    { name: "Panamera",    body_type: :sedan,       year: 2009 },
    { name: "Taycan",      body_type: :electric,    year: 2019 },
    { name: "Boxster",     body_type: :convertible, year: 1996 },
    { name: "Cayman",      body_type: :coupe,       year: 2006 },
    { name: "Carrera",     body_type: :sports,      year: 1963 },
    { name: "718",         body_type: :coupe,       year: 2016 },
    { name: "GT3",         body_type: :sports,      year: 1999 },
    { name: "Turbo",       body_type: :sports,      year: 1975 }
  ],

  # ---- BRITISH ----

  "Jaguar" => [
    { name: "XE",          body_type: :sedan,       year: 2015 },
    { name: "XF",          body_type: :sedan,       year: 2008 },
    { name: "XJ",          body_type: :sedan,       year: 1968 },
    { name: "F-Pace",      body_type: :suv,         year: 2016 },
    { name: "E-Pace",      body_type: :suv,         year: 2018 },
    { name: "I-Pace",      body_type: :electric,    year: 2018 },
    { name: "F-Type",      body_type: :sports,      year: 2013 },
    { name: "XK",          body_type: :coupe,       year: 1996 },
    { name: "S-Type",      body_type: :sedan,       year: 1999 },
    { name: "X-Type",      body_type: :sedan,       year: 2001 }
  ],

  "Land Rover" => [
    { name: "Defender",        body_type: :suv,     year: 1983 },
    { name: "Discovery",       body_type: :suv,     year: 1989 },
    { name: "Range-Rover",     body_type: :suv,     year: 1970 },
    { name: "Evoque",          body_type: :suv,     year: 2011 },
    { name: "Velar",           body_type: :suv,     year: 2017 },
    { name: "Sport",           body_type: :suv,     year: 2005 },
    { name: "Freelander",      body_type: :suv,     year: 1997 },
    { name: "LR2",             body_type: :suv,     year: 2007 },
    { name: "LR3",             body_type: :suv,     year: 2005 },
    { name: "LR4",             body_type: :suv,     year: 2009 }
  ],

  "Mini" => [
    { name: "Cooper",      body_type: :hatchback,   year: 2001 },
    { name: "Countryman",  body_type: :suv,         year: 2010 },
    { name: "Clubman",     body_type: :hatchback,   year: 2007 },
    { name: "Convertible", body_type: :convertible, year: 2005 },
    { name: "Paceman",     body_type: :suv,         year: 2013 },
    { name: "Coupe",       body_type: :coupe,       year: 2011 },
    { name: "Roadster",    body_type: :convertible, year: 2012 },
    { name: "One",         body_type: :hatchback,   year: 2001 },
    { name: "Electric",    body_type: :electric,    year: 2020 },
    { name: "JCW",         body_type: :hatchback,   year: 2002 }
  ],

  "Bentley" => [
    { name: "Continental",  body_type: :coupe,      year: 1952 },
    { name: "Flying-Spur",  body_type: :sedan,      year: 2005 },
    { name: "Bentayga",     body_type: :suv,        year: 2016 },
    { name: "Mulsanne",     body_type: :sedan,      year: 2010 },
    { name: "Arnage",       body_type: :sedan,      year: 1998 },
    { name: "Azure",        body_type: :convertible, year: 1995 },
    { name: "Brooklands",   body_type: :coupe,      year: 1992 },
    { name: "Turbo-R",      body_type: :sedan,      year: 1985 },
    { name: "T-Series",     body_type: :sedan,      year: 1965 },
    { name: "Eight",        body_type: :sedan,      year: 1984 }
  ],

  "Rolls-Royce" => [
    { name: "Phantom",      body_type: :sedan,      year: 1925 },
    { name: "Ghost",        body_type: :sedan,      year: 2009 },
    { name: "Wraith",       body_type: :coupe,      year: 2013 },
    { name: "Dawn",         body_type: :convertible, year: 2015 },
    { name: "Cullinan",     body_type: :suv,        year: 2018 },
    { name: "Silver-Shadow", body_type: :sedan,      year: 1965 },
    { name: "Silver-Spur",  body_type: :sedan,      year: 1980 },
    { name: "Corniche",     body_type: :convertible, year: 1971 },
    { name: "Spectre",      body_type: :electric,   year: 2023 }
  ],

  "Aston Martin" => [
    { name: "DB11",        body_type: :coupe,       year: 2016 },
    { name: "DB12",        body_type: :coupe,       year: 2023 },
    { name: "Vantage",     body_type: :sports,      year: 2005 },
    { name: "DBS",         body_type: :coupe,       year: 2007 },
    { name: "Rapide",      body_type: :sedan,       year: 2010 },
    { name: "Valkyrie",    body_type: :sports,      year: 2021 },
    { name: "Virage",      body_type: :coupe,       year: 1988 },
    { name: "Vanquish",    body_type: :coupe,       year: 2001 },
    { name: "DBX",         body_type: :suv,         year: 2020 },
    { name: "Lagonda",     body_type: :sedan,       year: 1974 }
  ],

  # ---- ITALIAN ----

  "Ferrari" => [
    { name: "488",         body_type: :sports,      year: 2015 },
    { name: "F8",          body_type: :sports,      year: 2019 },
    { name: "Roma",        body_type: :coupe,       year: 2020 },
    { name: "Portofino",   body_type: :convertible, year: 2018 },
    { name: "SF90",        body_type: :sports,      year: 2019 },
    { name: "LaFerrari",   body_type: :sports,      year: 2013 },
    { name: "California",  body_type: :convertible, year: 2009 },
    { name: "Enzo",        body_type: :sports,      year: 2002 },
    { name: "812",         body_type: :sports,      year: 2017 },
    { name: "Testarossa",  body_type: :sports,      year: 1984 },
    { name: "F40",         body_type: :sports,      year: 1987 }
  ],

  "Lamborghini" => [
    { name: "Huracan",     body_type: :sports,      year: 2014 },
    { name: "Aventador",   body_type: :sports,      year: 2011 },
    { name: "Urus",        body_type: :suv,         year: 2018 },
    { name: "Gallardo",    body_type: :sports,      year: 2003 },
    { name: "Murcielago",  body_type: :sports,      year: 2001 },
    { name: "Diablo",      body_type: :sports,      year: 1990 },
    { name: "Reventon",    body_type: :sports,      year: 2007 },
    { name: "Countach",    body_type: :sports,      year: 1974 },
    { name: "Sian",        body_type: :sports,      year: 2020 }
  ],

  "Maserati" => [
    { name: "Ghibli",      body_type: :sedan,       year: 1966 },
    { name: "Quattroporte", body_type: :sedan,       year: 1963 },
    { name: "Levante",     body_type: :suv,         year: 2016 },
    { name: "MC20",        body_type: :sports,      year: 2020 },
    { name: "GranTurismo", body_type: :coupe,       year: 2007 },
    { name: "GranCabrio",  body_type: :convertible, year: 2010 },
    { name: "Biturbo",     body_type: :coupe,       year: 1981 },
    { name: "Coupe",       body_type: :coupe,       year: 2002 },
    { name: "Spyder",      body_type: :convertible, year: 2002 }
  ],

  "Alfa Romeo" => [
    { name: "Giulia",      body_type: :sedan,       year: 2016 },
    { name: "Stelvio",     body_type: :suv,         year: 2017 },
    { name: "Tonale",      body_type: :suv,         year: 2022 },
    { name: "4C",          body_type: :sports,      year: 2013 },
    { name: "Giulietta",   body_type: :hatchback,   year: 2010 },
    { name: "Spider",      body_type: :convertible, year: 1966 },
    { name: "GTV",         body_type: :coupe,       year: 1994 },
    { name: "156",         body_type: :sedan,       year: 1997 },
    { name: "159",         body_type: :sedan,       year: 2005 },
    { name: "Brera",       body_type: :coupe,       year: 2005 }
  ],

  "Fiat" => [
    { name: "500",         body_type: :hatchback,   year: 1957 },
    { name: "500X",        body_type: :suv,         year: 2015 },
    { name: "500L",        body_type: :hatchback,   year: 2012 },
    { name: "Panda",       body_type: :hatchback,   year: 1980 },
    { name: "Tipo",        body_type: :sedan,       year: 1988 },
    { name: "Punto",       body_type: :hatchback,   year: 1993 },
    { name: "Uno",         body_type: :hatchback,   year: 1983 },
    { name: "Bravo",       body_type: :hatchback,   year: 1995 },
    { name: "Doblo",       body_type: :van,         year: 2001 },
    { name: "Spider",      body_type: :convertible, year: 1966 }
  ],

  # ---- KOREAN ----

  "Hyundai" => [
    { name: "Elantra",     body_type: :sedan,       year: 1990 },
    { name: "Sonata",      body_type: :sedan,       year: 1985 },
    { name: "Tucson",      body_type: :suv,         year: 2004 },
    { name: "Santa-Fe",    body_type: :suv,         year: 2001 },
    { name: "Palisade",    body_type: :suv,         year: 2020 },
    { name: "Kona",        body_type: :suv,         year: 2018 },
    { name: "Accent",      body_type: :sedan,       year: 1994 },
    { name: "Ioniq",       body_type: :electric,    year: 2016 },
    { name: "Veloster",    body_type: :hatchback,   year: 2012 },
    { name: "Venue",       body_type: :suv,         year: 2020 },
    { name: "Genesis",     body_type: :sedan,       year: 2009 }
  ],

  "Kia" => [
    { name: "Forte",       body_type: :sedan,       year: 2010 },
    { name: "K5",          body_type: :sedan,       year: 2021 },
    { name: "Sportage",    body_type: :suv,         year: 1993 },
    { name: "Sorento",     body_type: :suv,         year: 2003 },
    { name: "Telluride",   body_type: :suv,         year: 2020 },
    { name: "Soul",        body_type: :hatchback,   year: 2009 },
    { name: "Rio",         body_type: :sedan,       year: 2001 },
    { name: "Stinger",     body_type: :sedan,       year: 2018 },
    { name: "Carnival",    body_type: :van,         year: 2021 },
    { name: "EV6",         body_type: :electric,    year: 2022 },
    { name: "Niro",        body_type: :suv,         year: 2017 }
  ],

  "Genesis" => [
    { name: "G70",         body_type: :sedan,       year: 2018 },
    { name: "G80",         body_type: :sedan,       year: 2017 },
    { name: "G90",         body_type: :sedan,       year: 2017 },
    { name: "GV60",        body_type: :electric,    year: 2022 },
    { name: "GV70",        body_type: :suv,         year: 2021 },
    { name: "GV80",        body_type: :suv,         year: 2021 },
    { name: "Coupe",       body_type: :coupe,       year: 2009 },
    { name: "Sedan",       body_type: :sedan,       year: 2009 },
    { name: "Electric",    body_type: :electric,    year: 2022 },
    { name: "X",           body_type: :suv,         year: 2023 },
    { name: "Convertible", body_type: :convertible, year: 2025 }
  ],

  # ---- NORDIC ----

  "Volvo" => [
    { name: "XC40",        body_type: :suv,         year: 2018 },
    { name: "XC60",        body_type: :suv,         year: 2008 },
    { name: "XC90",        body_type: :suv,         year: 2003 },
    { name: "S60",         body_type: :sedan,       year: 2001 },
    { name: "S90",         body_type: :sedan,       year: 1998 },
    { name: "V60",         body_type: :wagon,       year: 2011 },
    { name: "V90",         body_type: :wagon,       year: 2016 },
    { name: "C40",         body_type: :electric,    year: 2022 },
    { name: "Polestar1",   body_type: :coupe,       year: 2019 },
    { name: "Polestar2",   body_type: :electric,    year: 2020 },
    { name: "C30",         body_type: :hatchback,   year: 2006 }
  ],

  # ---- FRENCH ----

  "Peugeot" => [
    { name: "208",         body_type: :hatchback,   year: 2012 },
    { name: "308",         body_type: :hatchback,   year: 2007 },
    { name: "508",         body_type: :sedan,       year: 2011 },
    { name: "2008",        body_type: :suv,         year: 2013 },
    { name: "3008",        body_type: :suv,         year: 2009 },
    { name: "5008",        body_type: :suv,         year: 2009 },
    { name: "RCZ",         body_type: :coupe,       year: 2010 },
    { name: "Partner",     body_type: :van,         year: 1996 },
    { name: "Boxer",       body_type: :van,         year: 1994 },
    { name: "Traveller",   body_type: :van,         year: 2016 },
    { name: "407",         body_type: :sedan,       year: 2004 }
  ],

  "Renault" => [
    { name: "Clio",        body_type: :hatchback,   year: 1990 },
    { name: "Megane",      body_type: :hatchback,   year: 1995 },
    { name: "Captur",      body_type: :suv,         year: 2013 },
    { name: "Koleos",      body_type: :suv,         year: 2008 },
    { name: "Talisman",    body_type: :sedan,       year: 2016 },
    { name: "Zoe",         body_type: :electric,    year: 2012 },
    { name: "Arkana",      body_type: :suv,         year: 2021 },
    { name: "Duster",      body_type: :suv,         year: 2010 },
    { name: "Scenic",      body_type: :van,         year: 1996 },
    { name: "Kangoo",      body_type: :van,         year: 1997 }
  ],

  # ---- CHINESE ----

  "BYD" => [
    { name: "Han",         body_type: :electric,    year: 2020 },
    { name: "Tang",        body_type: :suv,         year: 2015 },
    { name: "Qin",         body_type: :sedan,       year: 2013 },
    { name: "Dolphin",     body_type: :electric,    year: 2021 },
    { name: "Seal",        body_type: :electric,    year: 2022 },
    { name: "Atto3",       body_type: :electric,    year: 2022 },
    { name: "Song",        body_type: :suv,         year: 2015 },
    { name: "Yuan",        body_type: :suv,         year: 2016 },
    { name: "Destroyer",   body_type: :sedan,       year: 2022 },
    { name: "Frigate",     body_type: :truck,       year: 2022 }
  ],

  "Geely" => [
    { name: "Emgrand",     body_type: :sedan,       year: 2009 },
    { name: "Coolray",     body_type: :suv,         year: 2019 },
    { name: "Atlas",       body_type: :suv,         year: 2016 },
    { name: "Tugella",     body_type: :suv,         year: 2019 },
    { name: "Geometry",    body_type: :electric,    year: 2019 },
    { name: "Xingyue",     body_type: :suv,         year: 2019 },
    { name: "Panda",       body_type: :hatchback,   year: 2008 },
    { name: "Boyue",       body_type: :suv,         year: 2016 },
    { name: "Binrui",      body_type: :sedan,       year: 2018 }
  ]

}

# ============================================
# CREATE MODELS
# ============================================

models_data.each do |brand_name, models|
  brand = Brand.find_by(name: brand_name)
  next unless brand

  models.each do |model|
    CarModel.find_or_create_by!(name: model[:name], brand: brand) do |car_model|
      car_model.slug                 = model[:name].parameterize
      car_model.body_type            = CarModel.body_types[model[:body_type]]
      car_model.production_start_date = Date.new(model[:year], 1, 1)
      car_model.description          = "#{model[:name]} by #{brand_name}, available in the American market."
      car_model.user_id              = User.find_by(role: :admin).id || User.first.id
      car_model.active               = true
    end
    puts "Created model: #{model[:name]} (#{brand_name})"
  end
end

puts "Total car models: #{CarModel.count}"
