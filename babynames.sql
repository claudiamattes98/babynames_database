CREATE table vornamen
(
	jahr_id int,
    bezirk_id int,
    geschlecht_bin int,
    vorname varchar (30),
    anzahl int
 );   
 
 CREATE TABLE wohnbezirke
 ( 
	bezirk_id int PRIMARY KEY,
    bezirk_name varchar (30)
);

 CREATE TABLE jahre
 ( 
	jahr_id int PRIMARY KEY,
    jahr int
);

CREATE TABLE geschlecht
(
	geschlecht_bin int PRIMARY KEY,
    geschlecht_name varchar(30)
);

INSERT INTO geschlecht (geschlecht_bin, geschlecht_name) VALUES
    (1, 'männlich'),
    (2, 'weiblich');


USE babynames;
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\babynames\\OGDEXT_VORNAMEN_1.csv' INTO TABLE vornamen
CHARACTER SET utf8mb4
FIELDS terminated by ';'
IGNORE 1 Lines;

USE babynames;
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\babynames\\OGDEXT_VORNAMEN_1_C-JAHR-0.csv' INTO TABLE jahre
CHARACTER SET utf8mb4
FIELDS terminated by ';'
IGNORE 1 Lines;

USE babynames;
LOAD DATA LOCAL INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Data\\babynames\\OGDEXT_VORNAMEN_1_C-WOHNBEZIRK-0.csv' INTO TABLE wohnbezirke
CHARACTER SET utf8mb4
FIELDS terminated by ';'
IGNORE 1 Lines;

CREATE VIEW bezirke AS
SELECT bezirk_id, bezirk_name, 
	CASE
		WHEN SUBSTRING(bezirk_id, 1, 1) IN ('1') THEN 'Burgenland'
        WHEN SUBSTRING(bezirk_id, 1, 1) IN ('2') THEN 'Kärnten'
        WHEN SUBSTRING(bezirk_id, 1, 1) IN ('3') THEN 'Niederösterreich'
        WHEN SUBSTRING(bezirk_id, 1, 1) IN ('4') THEN 'Oberösterreich'
        WHEN SUBSTRING(bezirk_id, 1, 1) IN ('5') THEN 'Salzburg'
        WHEN SUBSTRING(bezirk_id, 1, 1) IN ('6') THEN 'Steiermark'
        WHEN SUBSTRING(bezirk_id, 1, 1) IN ('7') THEN 'Tirol'
        WHEN SUBSTRING(bezirk_id, 1, 1) IN ('8') THEN 'Vorarlberg'
        WHEN SUBSTRING(bezirk_id, 1, 1) IN ('9') THEN 'Wien'
        ELSE 'Unknown Bundesland'
	END AS bundesland
FROM wohnbezirke;


CREATE VIEW vornamen_sum_view AS
SELECT Vorname, sum(Anzahl) AS Gesamtanzahl
FROM vornamen
GROUP BY Vorname;




CREATE TABLE vornamen_counts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    Vorname VARCHAR(30),
    Anzahl INT
);

INSERT INTO vornamen_counts (Vorname, Anzahl)
SELECT Vorname, SUM(anzahl) AS Anzahl
FROM vornamen
GROUP BY Vorname;

CREATE VIEW vornamen_by_bundesland AS
SELECT
    v.vorname,
    w.bundesland,
    sum(v.anzahl)
FROM vornamen v
LEFT JOIN
    bezirke w ON v.bezirk_id = w.bezirk_id;


create VIEW geschlvorn AS
SELECT v1.vorname
FROM vornamen v1
JOIN vornamen v2 ON v1.Vorname = v2.Vorname
WHERE v1.geschlecht_bin = 1
  AND v2.geschlecht_bin = 2
group by v1.Vorname
order by v1.vorname;

SELECT v.vorname, sum(v.anzahl) AS Anzahl, v.geschlecht_bin, v.jahr_id, v.bezirk_id
FROM vornamen v
JOIN geschlvorn g ON v.vorname = g.vorname
GROUP BY v.vorname, v.geschlecht_bin, v.jahr_id, v.bezirk_id
ORDER BY v.vorname;

create TABLE names_per_year AS
SELECT vorname, jahr_id, geschlecht_bin, sum(anzahl) AS Anzahl
FROM vornamen
GROUP BY vorname, jahr_id, geschlecht_bin
ORDER BY Anzahl desc;

#male_most_pop_names
SELECT DISTINCT jahr_id, vorname, anzahl
FROM names_per_year
WHERE geschlecht_bin = '1'
ORDER BY Anzahl DESC;

#female_most_pop_names
SELECT DISTINCT jahr_id, vorname, anzahl
FROM names_per_year
WHERE geschlecht_bin = '2'
ORDER BY Anzahl DESC;