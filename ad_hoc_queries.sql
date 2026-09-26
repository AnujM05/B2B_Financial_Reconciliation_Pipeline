SELECT 
"Customer_Name", 
"Order_ID", 
"Transaction_Date",
"Amount_Billed",
RANK() OVER(ORDER BY "Amount_Billed" DESC) AS "Company_Wide_Rank",
SUM("Amount_Billed") OVER (PARTITION BY "Customer_Name") AS "Total_Owned_By_Customer"
FROM
exceptions_missing_sales
ORDER BY
"Amount_Billed" DESC;






With All_Invoices AS (
SELECT 
"Customer_Name", 
"Amount_Billed", 
'Settled' AS "Status" 
FROM 
reconciled_exact
UNION ALL
SELECT 
"Customer_Name",
"Amount_Billed",
'Settled' AS "Status"
FROM
reconciled_fuzzy
UNION ALL
SELECT 
"Customer_Name",
"Amount_Billed",
'unpaid' AS "Status"
FROM
exceptions_missing_sales
)
SELECT
"Customer_Name",
SUM("Amount_Billed") AS "Total_Billed",
SUM(CASE
WHEN "Status" = 'Settled' THEN "Amount_Billed"
ELSE 0
END) AS "Total_Recovered",
ROUND(
(SUM(CASE
WHEN "Status" = 'Settled' THEN "Amount_Billed"
ELSE 0
END) / SUM("Amount_Billed") * 100)::numeric
, 2) AS "Recovery_Percentage"
FROM
All_Invoices
GROUP BY
"Customer_Name"
ORDER BY 
"Recovery_Percentage" ASC;











SELECT
"Customer_Name",
"Order_ID",
"Amount_Billed",
"Transaction_Date",
CURRENT_DATE - "Transaction_Date"::DATE AS "Days_Overdue"
FROM
exceptions_missing_sales
WHERE
(CURRENT_DATE - "Transaction_Date"::DATE) > 15
ORDER BY
"Days_Overdue" DESC;