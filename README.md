# alternative-fuel-stations-locator

A simple Ruby program that uses APIs from National Renewable Energy Laboratory (NREL, https://developer.nrel.gov/docs/transportation/alt-fuel-stations-v1/) to search for alternative fuel stations based on different criteria. Was created as a part of a Ruby class.

Allows to search the stations based:  
  state (e.g., MA, NY)  
  zipcode (e.g., 11234)  
  type of the fuel (e.g., biodiesel, hydrogen)  

Identifies the stations that are in 5mi radius to the location that can be specified as:  
  street city state postal code  
  street city state  
  street postal code  
  postal code  
  city state  
