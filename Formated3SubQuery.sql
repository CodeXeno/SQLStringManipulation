SELECT FirstSet.DATE, 
       FirstSet.[Pos Journal], 
       FirstSet.Total, 
       FirstSet.[15 % VAT], 
       FirstSet.[25 % VAT], 
       SecondSet.BankAxept, 
       FirstSet.CreditCards, 
       FirstSet.Cash, 
       FirstSet.Vipps, 
       FirstSet.[Counted Cash], 
       FirstSet.Balance, 
       (CreditCards + CAST(LTRIM(RTRIM(LEFT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(ThirdSet.MAESTRO, '04847', ''), ',', '.'), '-', ''), '.00', ''), CHAR(10), CHAR(32)), CHAR(13), CHAR(32)), CHAR(160), CHAR(32)), CHAR(9), CHAR(32)), 'INNSAMLET', ''), ABS(CHARINDEX('-', REPLACE(ThirdSet.MAESTRO, '04847', '')) - 1)))) AS INT)) AS 'Total With Maestro'
FROM
(
    SELECT DISTINCT 
           SUM(DaysTakingLines.amount) OVER(PARTITION BY DaysTakings.PostingDate
           ORDER BY DaysTakings.PostingDate) AS CreditCards, 
           DaysTakings.PostingDate AS DATE, 
           DaysTakings.AccountingJournalNo AS 'Pos Journal', 
           (DaysTakings.SalesBank + Salescash + Mobile_mCash) AS Total, 
           (DaysTakings.SalesBank + Salescash + Mobile_mCash) AS "15 % VAT", 
           0 AS "25 % VAT", 
           DaysTakings.SalesCash AS Cash, 
           DaysTakings.Mobile_mCash AS Vipps, 
           DaysTakings.CountedCash AS 'Counted Cash', 
           DaysTakings.Balance AS Balance, 
           DaysTakings.DaysTakingID, 
           ReceiptText
    FROM DaysTakings
         JOIN DaysTakingLines ON DaysTakings.DaysTakingID = DaysTakingLines.DaysTakingID
    WHERE DaysTakingLines.BBSID IN(3, 4, 14, 5)
         AND SalesBank > 0
) AS FirstSet
INNER JOIN
(
    SELECT DISTINCT 
           SUM(DaysTakingLines.amount) OVER(PARTITION BY DaysTakings.PostingDate
           ORDER BY DaysTakings.PostingDate) AS "BankAxept", 
           DaysTakings.DaysTakingID
    FROM DaysTakings
         JOIN DaysTakingLines ON DaysTakings.DaysTakingID = DaysTakingLines.DaysTakingID
    WHERE DaysTakingLines.BBSID = 1
) AS SecondSet ON SecondSet.DaysTakingID = FirstSet.DaysTakingID
INNER JOIN
(
    SELECT DISTINCT 
           SUBSTRING(ReceiptText, CHARINDEX('maestro', ReceiptText) + 32, LEN(ReceiptText)) AS MAESTRO, 
           DaysTakings.DaysTakingID, 
           ReceiptText
    FROM DaysTakings
) AS ThirdSet ON FirstSet.DaysTakingID = ThirdSet.DaysTakingID;