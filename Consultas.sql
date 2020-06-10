-- 1) Listar todos los datos de todos los libros cuya cantidad de páginas sea superior al promedio.
SELECT * FROM Libros WHERE
LIBROS.Paginas > (SELECT AVG(LIBROS.Paginas) FROM Libros)
ORDER BY Paginas 

-- 2) Listar el nombre de todos los libros que tengan la valoración más baja.
SELECT L.Titulo, LXB.Valoracion FROM Libros AS L
INNER JOIN Libros_x_Biblioteca AS LXB ON L.ID = LXB.IDLibro
WHERE LXB.Valoracion = (SELECT MIN(Libros_x_Biblioteca.Valoracion) FROM Libros_x_Biblioteca)

-- 3) Listar el apellido y nombre de los autores y el título del libro de los registros cuyo precio supere el doble del precio promedio.
SELECT A.APELLIDOS, A. NOMBRES, L.TITULO, L.Precio FROM LIBROS AS L
INNER JOIN Autores_x_Libro AS AXL ON L.ID = AXL.IDLibro
INNER JOIN Autores AS A ON AXL.IDAutor = A.ID
WHERE L.Precio > (SELECT (AVG(Libros.Precio))*2 FROM Libros)

-- 4) Listar el apellido y nombre del usuario y el título del libro de quienes hayan pagado el precio de libro
--    a un valor mayor al cuádruple del precio promedio del sistema.
SELECT U.APELLIDOS, U.NOMBRES, L.TITULO, LXB.Precio FROM Usuarios AS U
INNER JOIN Bibliotecas AS B ON U.ID = B.IDUsuario
INNER JOIN Libros_x_Biblioteca AS LXB ON B.ID = LXB.IDBiblioteca
INNER JOIN Libros AS L ON LXB.IDLibro = L.ID
WHERE LXB.Precio > (SELECT AVG(LIBROS.PRECIO)*4 FROM LIBROS)

-- 5) Listar el apellido y nombre de los autores que no hayan escrito ningún libro.
SELECT A.APELLIDOS, A.NOMBRES FROM Autores AS A
WHERE A.ID NOT IN (SELECT Autores_x_Libro.IDAutor FROM Autores_x_Libro)

-- 6) Listar el nombre de todos los géneros de los cuales no haya libros escritos.
SELECT G.ID, G.NOMBRE FROM Generos AS G
WHERE G.ID NOT IN (SELECT Generos_x_Libro.IDGenero FROM Generos_x_Libro)

-- 7) Listar el nombre de todos los idiomas de los cuales no se poseen libros.
SELECT * FROM Idiomas
WHERE Idiomas.ID NOT IN (SELECT Libros.IDIdioma FROM Libros WHERE Libros.IDIdioma IS NOT NULL)

-- 8) Listar el nombre de todas las editoriales de las cuales no se poseen libros.
SELECT * FROM Editoriales
WHERE Editoriales.ID NOT IN (SELECT Libros.IDEditorial FROM Libros WHERE Libros.IDEditorial IS NOT NULL)

-- 9) Listar los títulos y precios de todos los libros que sean más baratos que todos los libros en idioma Inglés.
SELECT L.Titulo, L.Precio FROM Libros AS L
WHERE L.Precio < ALL (SELECT Libros.Precio FROM Libros
					INNER JOIN Idiomas AS I ON Libros.IDIdioma = I.ID
					WHERE I.Nombre LIKE 'Inglés')

-- 10) Listar los títulos, precio, apellidos y nombres de los autores de libros que sean más caros que todos los libros en idioma inglés.
SELECT L.Titulo, L.Precio, A.APELLIDOS, A.NOMBRES FROM Libros AS L
INNER JOIN Autores_x_Libro AS AXL ON L.ID = AXL.IDLibro
INNER JOIN Autores AS A ON AXL.IDAutor = A.ID
WHERE L.Precio > ALL (SELECT Libros.Precio FROM Libros
					INNER JOIN Idiomas AS I ON Libros.IDIdioma = I.ID
					WHERE I.Nombre LIKE 'Inglés')

-- 11) Listar los títulos de los libros y cantidad de páginas de los libros que sean más extensos que algún libro de la editorial Plaza y Janés.
SELECT L.Titulo, L.Paginas FROM Libros AS L
WHERE L.Paginas > ANY (SELECT LIBROS.Paginas FROM Libros
						INNER JOIN Editoriales AS E ON Libros.IDEditorial = E.ID
						WHERE E.Nombre LIKE 'Plaza y Janés')
ORDER BY L.Paginas

-- 12) Listar por cada libro el título y la cantidad de veces que fueron agregados a una biblioteca en medio digital
--     y la cantidad de veces que fueron agregados a una biblioteca en medio físico.
--     NOTA:  Medio digital → El valor del campo Medio es 'D' Medio físico → El valor del campo Medio es 'F'
SELECT L.TITULO,
	(SELECT COUNT(*) FROM Libros_x_Biblioteca AS LXB
	INNER JOIN Formatos AS F ON LXB.IDFormato = F.ID
	WHERE L.ID = LXB.IDLibro AND F.Medio LIKE 'D') AS [Cantidad Digital],
	(SELECT COUNT(*) FROM Libros_x_Biblioteca AS LXB
	INNER JOIN Formatos AS F ON LXB.IDFormato = F.ID
	WHERE L.ID = LXB.IDLibro AND F.Medio LIKE 'F') AS [Cantidad Fisico]
FROM LIBROS AS L

-- 13) Listar por cada país el nombre y la cantidad de autores de sexo masculino y la cantidad de autores de sexo femenino.
SELECT Nombre,
	(SELECT COUNT(*) FROM Autores AS A
	WHERE A.IDPais = Paises.ID AND A.Sexo LIKE 'M') AS [Cantidad Autores],
	(SELECT COUNT(*) FROM Autores AS A
	WHERE A.IDPais = Paises.ID AND A.Sexo LIKE 'F') AS [Cantidad Autoras]
FROM Paises

-- 14) Listar por cada usuario los nombres y apellidos, la cantidad de libros en formato digital y la cantidad de libros en formato físico.
SELECT U.Apellidos, U.Nombres,
	(SELECT COUNT(*) FROM Libros_x_Biblioteca AS LXB
	INNER JOIN Bibliotecas AS B ON LXB.IDBiblioteca = B.ID
	INNER JOIN Formatos AS F ON LXB.IDFormato = F.ID
	WHERE U.ID = B.IDUsuario AND F.Medio like 'D') AS [Cantidad Digital],
	(SELECT COUNT(*) FROM Libros_x_Biblioteca AS LXB
	INNER JOIN Bibliotecas AS B ON LXB.IDBiblioteca = B.ID
	INNER JOIN Formatos AS F ON LXB.IDFormato = F.ID
	WHERE U.ID = B.IDUsuario AND F.Medio like 'F') AS [Cantidad Fisico]
FROM Usuarios AS U

-- 15) Listar por cada autor el apellido y nombre y la cantidad de libros de su autoría en idioma Inglés y la cantidad de libros de su autoría
--     en idioma Español.
SELECT A.Apellidos, A.Nombres,
	(SELECT COUNT(*) FROM LIBROS AS L
	INNER JOIN Idiomas AS I ON L.IDIdioma = I.ID
	INNER JOIN Autores_x_Libro AS AXL ON L.ID = AXL.IDLibro
	WHERE A.ID = AXL.IDAutor AND I.Nombre LIKE 'Inglés') AS [Cantidad Inglés],
	(SELECT COUNT(*) FROM LIBROS AS L
	INNER JOIN Idiomas AS I ON L.IDIdioma = I.ID
	INNER JOIN Autores_x_Libro AS AXL ON L.ID = AXL.IDLibro
	WHERE A.ID = AXL.IDAutor AND I.Nombre LIKE 'Español') AS [Cantidad Español]
FROM Autores AS A

-- 16) Por cada género listar el nombre y el promedio de precio de los libros escritos antes a 1990 y el promedio de precio de los libros 
--     escritos después a 1990.
SELECT G.Nombre,
	(SELECT ISNULL(AVG(L.Precio),0) FROM Libros AS L
	INNER JOIN Generos_x_Libro AS GXL ON L.ID = GXL.IDLibro
	WHERE G.ID = GXL.IDGenero AND L.Año < 1990) AS [AVG Precio < 1990],
	(SELECT ISNULL(AVG(L.Precio),0) FROM Libros AS L
	INNER JOIN Generos_x_Libro AS GXL ON L.ID = GXL.IDLibro
	WHERE G.ID = GXL.IDGenero AND L.Año > 1990) AS [AVG Precio > 1990]
FROM Generos AS G

-- 17) Listar los títulos de los libros que hayan registrado más libros en medios digitales que en medios físicos.
SELECT L.TITULO FROM Libros AS L 
	WHERE (SELECT COUNT(*) FROM Libros_x_Biblioteca AS LXB
			INNER JOIN Formatos AS F ON LXB.IDFormato = F.ID
			WHERE L.ID = LXB.IDLibro AND F.MEDIO LIKE 'D') >
			(SELECT COUNT(*) FROM Libros_x_Biblioteca AS LXB
			INNER JOIN Formatos AS F ON LXB.IDFormato = F.ID
			WHERE L.ID = LXB.IDLibro AND F.MEDIO LIKE 'F')

-- 18) Listar los títulos de los libros que hayan registrado la misma cantidad de medios digitales que físicos pero que al menos hayan 
--     registrado por lo menos algún medio.
SELECT MI_TABLA.Titulo FROM
	(SELECT L.TITULO,
		(SELECT COUNT(*) FROM Libros_x_Biblioteca AS LXB
		INNER JOIN Formatos AS F ON LXB.IDFormato = F.ID
		WHERE L.ID = LXB.IDLibro AND F.MEDIO LIKE 'D') AS CANT_DIG,
		(SELECT COUNT(*) FROM Libros_x_Biblioteca AS LXB
		INNER JOIN Formatos AS F ON LXB.IDFormato = F.ID
		WHERE L.ID = LXB.IDLibro AND F.MEDIO LIKE 'F') AS CANT_FIS
	FROM Libros AS L) AS MI_TABLA
WHERE MI_TABLA.CANT_DIG > 0 AND MI_TABLA.CANT_FIS > 0 AND MI_TABLA.CANT_DIG = MI_TABLA.CANT_FIS

-- 19) Listar los países que registren más de un autor de sexo masculino y más de una autora de sexo femenino.
SELECT MI_TABLA.Nombre FROM
	(SELECT P.NOMBRE,
		(SELECT COUNT(*) FROM AUTORES AS A
		WHERE A.SEXO LIKE 'M' AND A.IDPais = P.ID) AS CANT_M,
		(SELECT COUNT(*) FROM AUTORES AS A
		WHERE A.SEXO LIKE 'F' AND A.IDPais = P.ID) AS CANT_F
	FROM PAISES AS P) AS MI_TABLA
WHERE MI_TABLA.CANT_M > 1 AND MI_TABLA.CANT_F > 1

-- 20) Listar la cantidad de países que no registren autoras de sexo femenino.
SELECT MI_TABLA.Nombre FROM
	(SELECT P.NOMBRE,
		(SELECT COUNT(*) FROM AUTORES AS A
		WHERE A.SEXO LIKE 'F' AND A.IDPais = P.ID) AS CANT_F
	FROM PAISES AS P) AS MI_TABLA
WHERE MI_TABLA.CANT_F = 0

-- 21) Listar los apellidos de los autores que hayan escrito más libros en Español que en Inglés pero que hayan escrito al menos un libro
--     en Inglés.
SELECT MI_TABLA.Apellidos FROM
	(SELECT  A.Apellidos,
		(SELECT COUNT(*) FROM Autores_x_Libro AS AXL
		INNER JOIN Libros AS L ON AXL.IDLibro = L.ID
		INNER JOIN Idiomas AS I ON L.IDIdioma = I.ID
		WHERE AXL.IDAutor = A.ID AND I.Nombre LIKE 'Español') AS CANT_ESP,
		(SELECT COUNT(*) FROM Autores_x_Libro AS AXL
		INNER JOIN Libros AS L ON AXL.IDLibro = L.ID
		INNER JOIN Idiomas AS I ON L.IDIdioma = I.ID
		WHERE AXL.IDAutor = A.ID AND I.Nombre LIKE 'Inglés') AS CANT_ING
	FROM AUTORES AS A) AS MI_TABLA
WHERE MI_TABLA.CANT_ING > 0 AND MI_TABLA.CANT_ESP > MI_TABLA.CANT_ING

--1
SELECT COUNT(*) FROM
	(SELECT U.APELLIDOS, 
		(SELECT COUNT(*) FROM Libros_x_Biblioteca AS LXB
		INNER JOIN Formatos AS F ON LXB.IDFormato = F.ID
		INNER JOIN Bibliotecas AS B ON LXB.IDBiblioteca = B.ID
		WHERE U.ID = B.IDUsuario AND F.Nombre LIKE 'PDF') AS CANT_PDF
	FROM Usuarios AS U) AS MI_TABLA
WHERE CANT_PDF = 0

--2

	SELECT U.APELLIDOS, MAX(L.PAGINAS), L.Titulo FROM LIBROS AS L
	INNER JOIN Libros_x_Biblioteca AS LXB ON L.ID = LXB.IDLibro
	INNER JOIN Bibliotecas AS B ON LXB.IDBiblioteca = B.ID
	INNER JOIN Usuarios AS U ON B.IDUsuario = U.ID
	WHERE U.ID = B.IDUsuario
	GROUP BY L.Titulo, U.APELLIDOS

--3
SELECT L.TITULO FROM Libros AS L
INNER JOIN Idiomas AS I ON L.IDIdioma = I.ID
WHERE I.Nombre LIKE 'Español' AND
L.Precio < (SELECT AVG(PRECIO) FROM Libros)
ORDER BY L.Titulo

--4
SELECT COUNT(MI_TABLA.APELLIDOS) FROM
	(SELECT A.APELLIDOS, 
		(SELECT COUNT(*) FROM LIBROS AS L
		INNER JOIN Idiomas AS I ON L.IDIdioma = I.ID
		INNER JOIN Autores_x_Libro AS AXL ON L.ID = AXL.IDLibro
		WHERE A.ID = AXL.IDAutor AND I.Nombre LIKE 'Inglés') AS CANT_ING,
		(SELECT COUNT(*) FROM LIBROS AS L
		INNER JOIN Idiomas AS I ON L.IDIdioma = I.ID
		INNER JOIN Autores_x_Libro AS AXL ON L.ID = AXL.IDLibro
		WHERE A.ID = AXL.IDAutor AND I.Nombre NOT LIKE 'Inglés') AS CANT_NO_ING
	FROM Autores AS A
	ORDER BY A.Apellidos) AS MI_TABLA
WHERE CANT_ING = 0 AND CANT_NO_ING > 0




