-- Q & A Section

-- Table: Questions
CREATE TABLE Questions (
   questionId INT AUTO_INCREMENT PRIMARY KEY,
   customerId INT NOT NULL,
   questionText TEXT NOT NULL,
   questionDate DATETIME DEFAULT CURRENT_TIMESTAMP,
   FOREIGN KEY (customerId) REFERENCES Customer(customerId) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Table: Answers
CREATE TABLE Answers (
   answerId INT AUTO_INCREMENT PRIMARY KEY,
   questionId INT NOT NULL,
   employeeSSN CHAR(11) NOT NULL,
   answerText TEXT NOT NULL,
   answerDate DATETIME DEFAULT CURRENT_TIMESTAMP,
   FOREIGN KEY (questionId) REFERENCES Questions(questionId) ON DELETE CASCADE ON UPDATE CASCADE,
   FOREIGN KEY (employeeSSN) REFERENCES Employee(ssn) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Index for Searching based on Question
CREATE FULLTEXT INDEX idx_questionText ON Questions (questionText);