class Users::RegistrationsController < Devise::RegistrationsController
  before_action :set_location_options, only: [ :new, :create ]

  private

  def set_location_options
    @country_options = [ [ "United States", "US" ], [ "Canada", "CA" ] ]
    @states_by_country = {
      "US" => [
        [ "Alabama", "AL" ], [ "Alaska", "AK" ], [ "Arizona", "AZ" ], [ "Arkansas", "AR" ], [ "California", "CA" ],
        [ "Colorado", "CO" ], [ "Connecticut", "CT" ], [ "Delaware", "DE" ], [ "Florida", "FL" ], [ "Georgia", "GA" ],
        [ "Hawaii", "HI" ], [ "Idaho", "ID" ], [ "Illinois", "IL" ], [ "Indiana", "IN" ], [ "Iowa", "IA" ],
        [ "Kansas", "KS" ], [ "Kentucky", "KY" ], [ "Louisiana", "LA" ], [ "Maine", "ME" ], [ "Maryland", "MD" ],
        [ "Massachusetts", "MA" ], [ "Michigan", "MI" ], [ "Minnesota", "MN" ], [ "Mississippi", "MS" ], [ "Missouri", "MO" ],
        [ "Montana", "MT" ], [ "Nebraska", "NE" ], [ "Nevada", "NV" ], [ "New Hampshire", "NH" ], [ "New Jersey", "NJ" ],
        [ "New Mexico", "NM" ], [ "New York", "NY" ], [ "North Carolina", "NC" ], [ "North Dakota", "ND" ], [ "Ohio", "OH" ],
        [ "Oklahoma", "OK" ], [ "Oregon", "OR" ], [ "Pennsylvania", "PA" ], [ "Rhode Island", "RI" ], [ "South Carolina", "SC" ],
        [ "South Dakota", "SD" ], [ "Tennessee", "TN" ], [ "Texas", "TX" ], [ "Utah", "UT" ], [ "Vermont", "VT" ],
        [ "Virginia", "VA" ], [ "Washington", "WA" ], [ "West Virginia", "WV" ], [ "Wisconsin", "WI" ], [ "Wyoming", "WY" ],
        [ "District of Columbia", "DC" ]
      ],
      "CA" => [
        [ "Alberta", "AB" ], [ "British Columbia", "BC" ], [ "Manitoba", "MB" ], [ "New Brunswick", "NB" ],
        [ "Newfoundland and Labrador", "NL" ], [ "Northwest Territories", "NT" ], [ "Nova Scotia", "NS" ], [ "Nunavut", "NU" ],
        [ "Ontario", "ON" ], [ "Prince Edward Island", "PE" ], [ "Quebec", "QC" ], [ "Saskatchewan", "SK" ], [ "Yukon", "YT" ]
      ]
    }
  end
end
