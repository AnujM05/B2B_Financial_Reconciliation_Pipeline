# B2B Financial Reconciliation & Revenue Analysis Pipeline

## 📌 The Business Problem
Corporate finance teams face a massive operational bottleneck when matching internal sales ledgers against actual bank deposits. Clients rarely pay under their exact registered names (e.g., "Reliance Retail" pays as "Rel Retail" or "RELIANCE"). Traditional database exact-match SQL joins fail on these variations, forcing analysts into hours of manual spreadsheet reconciliation and leaving significant revenue unallocated. 

This project is an end-to-end Data Engineering and Analytics solution built to automate this process, recover missing cash, and provide executive visibility into cash flow risks.

## 🛠️ Tech Stack
* **Data Engineering & ETL:** Python (Pandas, NumPy)
* **Algorithmic Matching:** RapidFuzz (String similarity/Fuzzy logic)
* **Data Warehousing:** PostgreSQL, SQLAlchemy
* **Data Analytics:** Advanced SQL (Window Functions, CTEs, Conditional Aggregation)
* **Data Visualization:** Power BI

## ⚙️ The Pipeline Architecture

### 1. Synthetic Data Generation (The Stress Test)
To simulate real-world accounting chaos, I engineered a Python script to generate an internal sales ledger of 100 perfect B2B invoices and a mutated bank statement. The script deliberately injects three real-world errors into the bank data:
* **Missing Payments:** Randomly drops 5% of transactions to simulate unpaid debt.
* **Clearance Delays:** Shifts transaction dates by 1–3 days to break strict date-matching.
* **Naming Mutations:** Alters 30% of corporate names (abbreviations, typos, capitalization) to simulate dirty banking data.

### 2. The Detective Engine (Fuzzy Matching)
I developed a two-pass Python algorithm to clean and reconcile the data:
* **Pass 1:** Normalizes text (lowercasing, stripping whitespace) for exact matches.
* **Pass 2:** Integrates `RapidFuzz` to evaluate string similarity for the remaining unmatched records. I enforced a strict **85% confidence threshold** to safely match abbreviated bank deposits back to the original client while mathematically preventing catastrophic "False Positives" in the accounting ledger.

### 3. The Data Contract (Strict Schema)
Before warehousing, the data passes through a Python-enforced "Data Contract." This function forces every output into a strict 10-column master schema with rigid data types (forcing monetary values to floats and cleaning DateTime objects). This guarantees the downstream SQL database is protected from fatal type-casting errors.

### 4. Data Warehousing & SQL Analytics
Using `SQLAlchemy`, the sanitized data is pushed to a local PostgreSQL data warehouse and partitioned into Exact Matches, Fuzzy Matches, and Exceptions. I developed ad-hoc SQL queries to extract immediate business intelligence:
* **Collections Priority:** Utilized Window Functions (`RANK()`, `SUM() OVER PARTITION`) to generate a dynamic hit-list, ranking clients by total outstanding debt.
* **Settlement Efficiency:** Built a digital pivot table using Common Table Expressions (CTEs) and `CASE WHEN` conditional aggregation to calculate the exact payment recovery percentage per client.
* **Risk Exposure:** Leveraged PostgreSQL date math to isolate unpaid invoices older than 15 days, identifying critical aging debt.

## 📊 The Executive Command Center (Power BI)
I connected Power BI directly to the PostgreSQL warehouse to build an automated reporting dashboard for the Finance Director. 

**Key Features:**
* **Macro KPIs:** Instantly displays Total Billed, Matched Revenue, and Unallocated Bank Deposits.
* **Algorithmic Transparency:** A donut chart visually proves the pipeline's success (76% exact match, 13% fuzzy recovery, 11% isolated exceptions).
* **Debt Spotlight:** A clustered bar chart exposes the exact financial shortfall per client (Billed vs. Settled).
* **Actionable Ledger:** A granular table provides the Collections Team with the exact missing Invoice IDs and Indian Rupee (Lakh) amounts to chase daily.

## 🚀 Business Impact
This pipeline successfully processed a ₹2.73M ledger, securely matched ₹2.43M in revenue, and precisely isolated ₹300K in missing invoices and ₹94K in unallocated rogue bank deposits. It transforms a manual, error-prone accounting chore into an automated, zero-loss financial reconciliation engine.

## 💼 Financial Mechanics & Operational Handoff
To bridge the gap between data engineering and business operations, this pipeline is designed around the standard B2B "Order-to-Cash" cycle. 

### 1. The Business Context
In B2B commerce, clients (e.g., Enterprise Corporations) are billed via legal Invoices after services are rendered. They are required to transfer funds to our corporate bank account within a strict time window, as B2B payment terms commonly run Net 30 to Net 90 days. This dashboard tracks that exact cash movement and settlement.

### 2. The Metrics Translated
* **Amount Billed (₹27.32 Lakhs):** The total expected revenue based on internal sales invoices.
* **Matched / Settled Cash (₹24.3 Lakhs):** The success metric. This cash has physically cleared the bank and our algorithm has successfully linked it to the exact client and invoice.
* **Algorithm Filters:** Matches are achieved either via **Exact Match** (flawless bank data) or **Fuzzy Match** (utilizing `RapidFuzz` string similarity to bypass messy, abbreviated banking data).
* **Missing Revenue (₹300k):** Known unpaid debt. The client was billed, but the bank has not received the funds.
* **Unallocated Cash (₹94k):** Mystery bank deposits. Funds have cleared our bank, but cannot be tied to a known invoice, preventing legal revenue recognition.

### 3. Departmental Workflow (The Handoff)
This automated pipeline delegates specific insights to the appropriate finance teams:
* **The Finance Director:** Utilizes the dashboard as a daily command center to monitor working capital and order-to-cash efficiency.
* **Accounts Receivable (Cash Application):** Takes ownership of the **Unallocated Cash (₹94k)**, acting as financial detectives to categorize mystery deposits and legally record them as revenue. 
* **The Collections Team:** Takes ownership of the **Missing Revenue (₹300k)**. Because it is up to the AR and collections teams to make sure payment is collected, they utilize the SQL-generated hit-list to aggressively pursue delinquent clients and enforce credit terms.
