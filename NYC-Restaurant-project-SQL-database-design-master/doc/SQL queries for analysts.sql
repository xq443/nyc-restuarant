# 1. find the most common violations and violation trends
q1 = """SELECT violation_description, count
FROM
(SELECT violation_code, COUNT(*) FROM
restaurants_violations NATURAL JOIN violations NATURAL JOIN restaurants
GROUP BY violation_code
ORDER BY count DESC) AS FOO
NATURAL LEFT OUTER JOIN
(SELECT DISTINCT violation_code, violation_description FROM
restaurants_violations NATURAL JOIN violations
) AS LOO
ORDER BY count DESC;"""


# 2. identify restaurants by the number of violations (rank) 

# option 1: group by camis
q2_1 = """SELECT restaurant_name_violations, camis, incedents_count, rank FROM
restaurants NATURAL RIGHT JOIN (
SELECT *
FROM
(SELECT camis, count(*) as incedents_count, DENSE_RANK () OVER (ORDER BY count(*) DESC) as rank
FROM
(restaurants JOIN restaurants_incidents USING(camis)) AS FOO
GROUP BY camis) AS LOO
WHERE rank <=20
) AS LUU
ORDER BY rank """

# option 2:  group by restaurants name
q2_2 = """SELECT restaurant_name_violations, incedents_count, rank
FROM
(
SELECT restaurant_name_violations, count(*) as incedents_count, DENSE_RANK () OVER (ORDER BY count(*) DESC) as rank
FROM
(restaurants as r JOIN restaurants_incidents as ri on r.camis = ri.camis) AS FOO
GROUP BY restaurant_name_violations
) AS LOO
WHERE rank <=100;"""


# 3. if there are more violations in weekdays or weekends?/summer/winter

q3 = """SELECT
  day_of_the_week,
  COUNT(*) AS num
FROM
  restaurants_violations
GROUP BY
  day_of_the_week"""

  
  
# 4. Which cuisine tends to have more violations

q4 = """SELECT c.cuisine_name, count(rv.violation_code) as violations
,rank() over (order by count(rv.violation_code) desc) as s_rank
from restaurants_violations as rv
join restaurants_cuisine as rc on rv.camis=rc.camis
join cuisines as c on c.cuisine_id = rc.cuisine_id
GROUP BY c.cuisine_name"""


  
# 5. group restaurants with a lot of violations together

q5 = """Select restaurant_name_violations, violations,
CASE
    WHEN violations > 10  THEN 'The restaurant has many violations'
    WHEN violations < 10 AND violations >5 and violations =5 THEN 'The restaurant has some violations'
WHEN violations = 0 THEN 'The restaurant does not have any violation'
ELSE 'The restaurants has a few violations'
END AS Violations_group
FROM
(select r.restaurant_name_violations, count(rv.violation_code) as violations
from restaurants_violations as rv
join restaurants as r on r.camis=rv.camis
group by r.restaurant_name_violations) as foo
order by violations_group"""

  
# 6. What are the most common liquor license types for each of the boroughs

q6 = """SELECT borough_name, license_type_code, COUNT(license_type_code)
FROM (
SELECT DISTINCT(camis), license_type_code, borough_name
FROM license_type
NATURAL JOIN restaurants_licenses
NATURAL JOIN restaurants) as sub
GROUP BY borough_name, license_type_code
ORDER BY borough_name, COUNT DESC;
"""


# 7. Ranking restaurant cuisines by the number of incidents

q7 = """SELECT cuisine_name, comp_count
FROM
(SELECT cuisine_name, COUNT(food_poisoning_complaint_id) as comp_count, rank() over (order by COUNT(food_poisoning_complaint_id) desc)
FROM restaurants_incidents as ri
NATURAL JOIN restaurants_cuisine AS rc
GROUP BY cuisine_name
ORDER BY comp_count DESC) as sub
WHERE rank <= 5;"""


# 8. Identify the number of restaurant location types within each borough
q8 = """SELECT borough_name, location_type, count(CAMIS)
FROM restaurants
NATURAL JOIN location_types
GROUP BY borough_name, location_type
ORDER BY borough_name, count DESC;"""


# 9. Identify zip codes with most violations
q9 = """
SELECT zip, count(violation_code) as violations, rank() over (order by count(violation_code) desc) as rank
FROM restaurants
NATURAL JOIN restaurants_violations
GROUP BY zip;
"""

# 10. Identify restuarants by incidents_group
q10 = """Select restaurant_name_violations, incidents,
CASE
    WHEN incidents > 10  THEN 'The restaurant has many food poisoning incidents'
    WHEN incidents < 10 AND incidents >5 and incidents =5 THEN 'The restaurant has some food poisoning incidents'
WHEN incidents = 0 THEN 'The restaurant does not have any food poisoning incident'
ELSE 'The restaurants has a few food poisoning incidents'
END AS incidents_group
FROM
(select r.restaurant_name_violations, count(ri.food_poisoning_complaint_id) as incidents
from restaurants_incidents as ri
join restaurants as r on r.camis=ri.camis
group by r.restaurant_name_violations) as foo
order by incidents_group"""
