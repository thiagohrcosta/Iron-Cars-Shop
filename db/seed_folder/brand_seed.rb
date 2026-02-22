# ============================================
# ADMIN USER
# ============================================

admin = User.find_or_create_by!(email: "admin@ironcars.com") do |user|
  user.password = "12345678"
  user.full_name = "Iron Cars System Admin"
  user.document_id = "00000000000"
  user.phone_number = "+1-000-000-0000"

  user.address_street = "System Street"
  user.address_number = "1"
  user.address_complement = "Headquarters"
  user.address_neighborhood = "Downtown"
  user.address_city = "New York"
  user.address_state = "NY"
  user.address_zip_code = "10001"
  user.address_country = "United States"

  user.role = :admin
end

# ============================================
# BRANDS DATA
# ============================================

brands_data = [
  # American
  [ "Ford", "United States", 1903 ],
  [ "Chevrolet", "United States", 1911 ],
  [ "GMC", "United States", 1911 ],
  [ "Cadillac", "United States", 1902 ],
  [ "Tesla", "United States", 2003 ],
  [ "Dodge", "United States", 1900 ],
  [ "Chrysler", "United States", 1925 ],
  [ "Jeep", "United States", 1941 ],
  [ "Lincoln", "United States", 1917 ],
  [ "Ram", "United States", 2010 ],
  [ "Buick", "United States", 1899 ],

  # Japanese
  [ "Toyota", "Japan", 1937 ],
  [ "Honda", "Japan", 1948 ],
  [ "Nissan", "Japan", 1933 ],
  [ "Mazda", "Japan", 1920 ],
  [ "Subaru", "Japan", 1953 ],
  [ "Mitsubishi", "Japan", 1870 ],
  [ "Lexus", "Japan", 1989 ],
  [ "Infiniti", "Japan", 1989 ],
  [ "Acura", "Japan", 1986 ],

  # German
  [ "BMW", "Germany", 1916 ],
  [ "Mercedes-Benz", "Germany", 1926 ],
  [ "Audi", "Germany", 1909 ],
  [ "Volkswagen", "Germany", 1937 ],
  [ "Porsche", "Germany", 1931 ],

  # British
  [ "Jaguar", "United Kingdom", 1922 ],
  [ "Land Rover", "United Kingdom", 1948 ],
  [ "Mini", "United Kingdom", 1959 ],
  [ "Bentley", "United Kingdom", 1919 ],
  [ "Rolls-Royce", "United Kingdom", 1906 ],
  [ "Aston Martin", "United Kingdom", 1913 ],

  # Italian
  [ "Ferrari", "Italy", 1939 ],
  [ "Lamborghini", "Italy", 1963 ],
  [ "Maserati", "Italy", 1914 ],
  [ "Alfa Romeo", "Italy", 1910 ],
  [ "Fiat", "Italy", 1899 ],

  # Korean
  [ "Hyundai", "South Korea", 1967 ],
  [ "Kia", "South Korea", 1944 ],
  [ "Genesis", "South Korea", 2015 ],

  # Swedish
  [ "Volvo", "Sweden", 1927 ],

  # French
  [ "Peugeot", "France", 1810 ],
  [ "Renault", "France", 1899 ],

  # Chinese
  [ "BYD", "China", 1995 ],
  [ "Geely", "China", 1986 ]
]

# ============================================
# CREATE BRANDS
# ============================================

brands_data.each do |name, country, founded_year|
  Brand.find_or_create_by!(name: name) do |brand|
    brand.slug = name.parameterize
    brand.country = country
    brand.founded_in = founded_year.to_s
    brand.description = "#{name} is an automotive manufacturer founded in #{founded_year} in #{country}. It plays a significant role in the global automotive market."
    brand.user = admin
    brand.active = true
  end
end

puts "Seed completed successfully. Total brands: #{Brand.count}"
