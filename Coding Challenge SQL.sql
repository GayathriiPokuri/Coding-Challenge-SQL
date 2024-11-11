create database virtual_art_gallery
use virtual_art_gallery

-- Create the Artists table
CREATE TABLE Artists (
 ArtistID INT PRIMARY KEY,
 Name VARCHAR(255) NOT NULL,
 Biography TEXT,
 Nationality VARCHAR(100));

-- Create the Categories table
CREATE TABLE Categories (
 CategoryID INT PRIMARY KEY,
 Name VARCHAR(100) NOT NULL);

-- Create the Artworks table
CREATE TABLE Artworks (
 ArtworkID INT PRIMARY KEY,
 Title VARCHAR(255) NOT NULL,
 ArtistID INT,
 CategoryID INT,
 Year INT,
 Description TEXT,
 ImageURL VARCHAR(255),
 FOREIGN KEY (ArtistID) REFERENCES Artists (ArtistID),
 FOREIGN KEY (CategoryID) REFERENCES Categories (CategoryID));

 -- Create the Exhibitions table
CREATE TABLE Exhibitions (
 ExhibitionID INT PRIMARY KEY,
 Title VARCHAR(255) NOT NULL,
 StartDate DATE,
 EndDate DATE,
 Description TEXT);
-- Create a table to associate artworks with exhibitions
CREATE TABLE ExhibitionArtworks (
 ExhibitionID INT,
 ArtworkID INT,
 PRIMARY KEY (ExhibitionID, ArtworkID),
 FOREIGN KEY (ExhibitionID) REFERENCES Exhibitions (ExhibitionID),
 FOREIGN KEY (ArtworkID) REFERENCES Artworks (ArtworkID));

-- Insert sample data into the Artists table
INSERT INTO Artists (ArtistID, Name, Biography, Nationality) VALUES
 (1, 'Pablo Picasso', 'Renowned Spanish painter and sculptor.', 'Spanish'),
 (2, 'Vincent van Gogh', 'Dutch post-impressionist painter.', 'Dutch'),
 (3, 'Leonardo da Vinci', 'Italian polymath of the Renaissance.', 'Italian');

-- Insert sample data into the Categories table
INSERT INTO Categories (CategoryID, Name) VALUES
 (4, 'Painting'),                                                 
 (5, 'Sculpture'),
 (6, 'Photography')

-- Insert sample data into the Artworks table
INSERT INTO Artworks (ArtworkID, Title, ArtistID, CategoryID, Year, Description, ImageURL) VALUES
 (1, 'Starry Night', 3, 1, 1889, 'A famous painting by Vincent van Gogh.', 'starry_night.jpg'),
 (2, 'Mona Lisa', 2, 1, 1503, 'The iconic portrait by Leonardo da Vinci.', 'mona_lisa.jpg'),
 (3, 'Guernica', 1, 1, 1937, 'Pablo Picassos powerful anti-war mural.', 'guernica.jpg')

-- Insert sample data into the Exhibitions table
INSERT INTO Exhibitions (ExhibitionID, Title, StartDate, EndDate, Description) VALUES
 (1, 'Modern Art Masterpieces', '2023-01-01', '2023-03-01', 'A collection of modern art masterpieces.'),
 (2, 'Renaissance Art', '2023-04-01', '2023-06-01', 'A showcase of Renaissance art treasures.');

 -- Insert artworks into exhibitions
INSERT INTO ExhibitionArtworks (ExhibitionID, ArtworkID) VALUES
 (1, 1),
 (1, 2),
 (1, 3),
 (2, 2);

--1. Retrieve the names of all artists along with the number of artworks they have in the gallery, and list them in descending order of the number of artworks.

SELECT  Artists.Name AS ArtistName,
    COUNT(Artworks.ArtworkID) AS ArtworkCount
FROM  Artists
LEFT JOIN Artworks ON Artists.ArtistID = Artworks.ArtistID
GROUP BY  Artists.Name
ORDER BY ArtworkCount DESC

--2. List the titles of artworks created by artists from 'Spanish' and 'Dutch' nationalities, and order them by the year in ascending order.

SELECT Artworks.Title AS ArtworkTitle,Artists.Nationality,Artworks.Year
FROM Artworks
JOIN Artists ON Artworks.ArtistID = Artists.ArtistID
WHERE Artists.Nationality IN ('Spanish', 'Dutch')
ORDER BY Artworks.Year ASC

--3. Find the names of all artists who have artworks in the 'Painting' category, and the number of artworks they have in this category.

SELECT Artists.Name AS ArtistName,
    COUNT(Artworks.ArtworkID) AS PaintingArtworkCount
FROM Artists
JOIN Artworks ON Artists.ArtistID = Artworks.ArtistID
JOIN Categories ON Artworks.CategoryID = Categories.CategoryID
WHERE Categories.Name = 'Painting'
GROUP BY Artists.Name
ORDER BY PaintingArtworkCount DESC

--4. List the names of artworks from the 'Modern Art Masterpieces' exhibition, along with their artists and categories.

SELECT ar.Title AS ArtworkTitle, 
    (SELECT a.Name FROM Artists a WHERE a.ArtistID = ar.ArtistID) AS ArtistName, 
    (SELECT c.Name FROM Categories c WHERE c.CategoryID = ar.CategoryID) AS CategoryName
FROM Artworks ar
WHERE ar.ArtworkID IN (
        SELECT ea.ArtworkID
        FROM ExhibitionArtworks ea
        JOIN Exhibitions e ON ea.ExhibitionID = e.ExhibitionID
        WHERE e.Title = 'Modern Art Masterpieces');

		SELECT*FROM Categories,artworks
--5. Find the artists who have more than two artworks in the gallery.

SELECT Name AS ArtistName
FROM Artists
WHERE ArtistID IN (
SELECT ArtistID
FROM Artworks
GROUP BY ArtistID
HAVING COUNT(ArtworkID) > 2)

--6. Find the titles of artworks that were exhibited in both 'Modern Art Masterpieces' and 'Renaissance Art' exhibitions

SELECT ar.Title AS ArtworkTitle
FROM Artworks ar
JOIN ExhibitionArtworks ea1 ON ar.ArtworkID = ea1.ArtworkID
JOIN Exhibitions e1 ON ea1.ExhibitionID = e1.ExhibitionID
JOIN ExhibitionArtworks ea2 ON ar.ArtworkID = ea2.ArtworkID
JOIN Exhibitions e2 ON ea2.ExhibitionID = e2.ExhibitionID
WHERE e1.Title = 'Modern Art Masterpieces' AND e2.Title = 'Renaissance Art';

SELECT*FROM Categories

--7.find the total number of artworks in each category

SELECT Name AS CategoryName,
    (SELECT COUNT(*) FROM Artworks ar WHERE ar.CategoryID = c.CategoryID) AS TotalArtworks
FROM Categories c;

--8. List artists who have more than 3 artworks in the gallery.
--(Similar to question 5)
SELECT Name AS ArtistName
FROM Artists
WHERE ArtistID IN (
SELECT ArtistID
FROM Artworks
GROUP BY ArtistID
HAVING COUNT(ArtworkID) > 3)

--9. Find the artworks created by artists from a specific nationality (e.g., Spanish).

SELECT Title AS ArtworkTitle
FROM Artworks
WHERE ArtistID IN (
SELECT ArtistID
FROM Artists
WHERE Nationality = 'Spanish')

--10. List exhibitions that feature artwork by both Vincent van Gogh and Leonardo da Vinci.

SELECT e.Title AS ExhibitionTitle
FROM Exhibitions e
JOIN ExhibitionArtworks ea ON e.ExhibitionID = ea.ExhibitionID
JOIN Artworks ar ON ea.ArtworkID = ar.ArtworkID
JOIN Artists a ON ar.ArtistID = a.ArtistID
WHERE a.Name IN ('Vincent van Gogh', 'Leonardo da Vinci')
GROUP BY e.ExhibitionID, e.Title
HAVING COUNT(DISTINCT a.Name) = 2;

--11. Find all the artworks that have not been included in any exhibition.

SELECT ar.Title AS ArtworkTitle
FROM Artworks ar
LEFT JOIN ExhibitionArtworks ea ON ar.ArtworkID = ea.ArtworkID
WHERE ea.ExhibitionID IS NULL;

--12. List artists who have created artworks in all available categories.

SELECT a.Name AS ArtistName
FROM Artists a
JOIN Artworks ar ON a.ArtistID = ar.ArtistID
JOIN Categories c ON ar.CategoryID = c.CategoryID
GROUP BY  a.ArtistID, a.Name
HAVING COUNT(DISTINCT ar.CategoryID) = (SELECT COUNT(*) FROM Categories);


--13. List the total number of artworks in each category.

-- Same question as 7th

--14. Find the artists who have more than 2 artworks in the gallery.

-- Same question as 5th

--15. List the categories with the average year of artworks they contain, only for categories with more than 1 artwork.

SELECT Name AS CategoryName,
(SELECT AVG(Year) FROM Artworks ar WHERE ar.CategoryID = c.CategoryID) AS AverageYear
FROM  Categories c
WHERE (SELECT COUNT(*) FROM Artworks ar WHERE ar.CategoryID = c.CategoryID) > 1;

--16. Find the artworks that were exhibited in the 'Modern Art Masterpieces' exhibition.

SELECT ar.Title AS ArtworkTitle
FROM Artworks ar
JOIN ExhibitionArtworks ea ON ar.ArtworkID = ea.ArtworkID
JOIN Exhibitions e ON ea.ExhibitionID = e.ExhibitionID
WHERE e.Title = 'Modern Art Masterpieces';

--17. Find the categories where the average year of artworks is greater than the average year of all artworks.

SELECT c.Name AS CategoryName,AVG(ar.Year) AS AverageYear
FROM Categories c
JOIN Artworks ar ON c.CategoryID = ar.CategoryID
GROUP BY c.CategoryID, c.Name
HAVING AVG(ar.Year) > (SELECT AVG(Year) FROM Artworks);

--18. List the artworks that were not exhibited in any exhibition.

--Same question as 11th

--19. Show artists who have artworks in the same category as "Mona Lisa."

SELECT a.Name AS ArtistName
FROM Artists a
JOIN Artworks ar ON a.ArtistID = ar.ArtistID
WHERE ar.CategoryID = (
        SELECT CategoryID 
        FROM Artworks 
        WHERE Title = 'Mona Lisa')AND ar.Title <> 'Mona Lisa';

--20. List the names of artists and the number of artworks they have in the gallery.

SELECT a.Name AS ArtistName,
    (SELECT COUNT(*) FROM Artworks ar WHERE ar.ArtistID = a.ArtistID) AS ArtworkCount
FROM Artists a;


