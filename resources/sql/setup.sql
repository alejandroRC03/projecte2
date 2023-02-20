--CREATE USER 'dev'@'%' IDENTIFIED BY 'devpassword';
--GRANT ALL PRIVILEGES ON
--CREATE DATABASE bbdduniversitat;
--USE bbdduniversitat;

CREATE TABLE professors (
    dni VARCHAR(9) NOT NULL,
    nom VARCHAR(10) NOT NULL,
    cognoms VARCHAR(10) NOT NULL,
    direccio VARCHAR(100) NOT NULL
);
INSERT INTO professors
VALUES
  ('12345678A', 'Pedro', 'Pérez', 'Calle 1, 123'),
  ('23456789B', 'María', 'García', 'Calle 2, 456'),
  ('34567890C', 'Juan', 'Rodríguez', 'Calle 3, 789'),
  ('45678901D', 'Ana', 'Martínez', 'Calle 4, 321'),
  ('56789012E', 'Lucía', 'Sánchez', 'Calle 5, 654');



CREATE TABLE assignatures (
    nom VARCHAR(15) NOT NULL,
    codi VARCHAR(10) NOT NULL
);
INSERT INTO assignatures
VALUES
  ('MAT101', 'Matemáticas I'),
  ('FIS102', 'Física I'),
  ('BIO103', 'Biología'),
  ('HIS104', 'Historia'),
  ('LIT105', 'Literatura');




CREATE TABLE professors_assignatures (
    id INT AUTO_INCREMENT PRIMARY KEY,
    professor_id INT NOT NULL,
    assignatura_id INT NOT NULL,
    FOREIGN KEY (professor_id) REFERENCES professors (id),
    FOREIGN KEY (assignatura_id) REFERENCES assignatures (id)
);

INSERT INTO professors_assignatures  VALUES
('12345678A', 'ASG1'),
('12345678A', 'ASG2'),
('87654321B', 'ASG3'),
('87654321B', 'ASG4'),
('55555555C', 'ASG5');




CREATE TABLE estudiants (
    dni VARCHAR(10) NOT NULL,
    nom VARCHAR(50) NOT NULL,
    cognoms VARCHAR(100) NOT NULL,
    direccio VARCHAR(200) NOT NULL,
    telefon VARCHAR(15) NOT NULL,
    naixement DATE NOT NULL,
    expedient INT NOT NULL,
);

INSERT INTO estudiants VALUES
('11111111A', 'Ana', 'Sorai', 'C/Alejandra 123', '654347893', '1999-01-01', '00001'),
('22222222B', 'Jon', 'Diaz', 'C/Pau 456', '688293564', '1998-02-02', '00002'),
('33333333C', 'Jan', 'Dominguez', 'C/Joel 789', '622093378', '1997-03-03', '00003'),
('44444444D', 'Marc', 'Jolo', 'C/Papu 012', '6273645', '1996-04-04', '00004'),
('55555555E', 'Ricard', 'Lopez', 'C/Luis 345', '689875244', '1995-05-05', '00005');





CREATE TABLE bicicleta (
    id INT AUTO_INCREMENT PRIMARY KEY,
estudiant_id INT NOT NULL,
    FOREIGN KEY (estudiant_id) REFERENCES estudiants (id)
);

INSERT INTO bicicleta VALUES
('1');
