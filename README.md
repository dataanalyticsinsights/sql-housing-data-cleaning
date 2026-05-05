🏠 Housing Data Cleaning Project (SQL)
📌 Overview

This project focuses on cleaning and preparing a housing dataset using SQL.
The goal was to transform raw, inconsistent data into a structured and analysis-ready format.

🧹 Data Cleaning Steps
1. Standardized Date Format
Converted SaleDate from text format (MM/DD/YYYY) to SQL date format (YYYY-MM-DD).
2. Handled Missing Data
Checked for missing PropertyAddress values.
Filled missing values using matching ParcelID.
3. Split Address Columns
Broke PropertyAddress into:
PropertySplitAddress
PropertySplitCity
Split OwnerAddress into:
OwnerSplitAddress
OwnerSplitCity
OwnerSplitState

5. Standardized Categorical Data
Converted SoldAsVacant values:
Y → Yes
N → No

7. Removed Duplicates
Identified duplicates using:
ParcelID
SalePrice
SaleDate
LegalReference
Used ROW_NUMBER() to filter unique records in a clean dataset.

9. Cleaned Text Data
Trimmed leading/trailing spaces
Removed duplicate spaces inside address fields

11. Created Final Clean Dataset
Built a clean view housing_final
Renamed columns using snake_case for readability
📊 Example Analysis
SELECT property_city, AVG(sale_price)
FROM housing_final
GROUP BY property_city;
📁 Files
housing_data_cleaning.sql → Full SQL cleaning process
housing_cleaned.csv (optional) → Final cleaned dataset
🧠 Key Skills Demonstrated
Data cleaning in SQL
Data transformation
Handling missing values
String manipulation
Window functions (ROW_NUMBER)
Creating views for clean datasets
🚀 Conclusion

The dataset was successfully cleaned and structured, making it suitable for analysis and visualization.# sql-housing-data-cleaning
SQL project cleaning and preparing housing data for analysis (date standardization, address splitting, duplicate handling).

📚 What I Learned
How to clean real-world messy data using SQL
Converting text data into proper date formats
Handling missing values using joins
Splitting complex columns (addresses) into structured fields
Standardizing inconsistent data (e.g., Y/N → Yes/No)
Using window functions (ROW_NUMBER()) to identify and handle duplicates
Cleaning text data by removing extra spaces and inconsistencies
Creating views to build a clean, analysis-ready dataset
Writing clear, structured SQL queries step-by-step
Understanding differences between SQL environments (MySQL vs SQL Server vs SQLite)

💡 Challenges Faced
Dealing with SQL safe update mode restrictions
Handling different date formats during conversion
Managing duplicate removal without crashing the database
Understanding why some SQL functions don’t work across different systems

🚀 What I Would Improve
Convert all numeric columns to proper numeric data types
Add indexes to improve query performance
Build a dashboard (Tableau or Power BI) using the cleaned dataset
Automate the cleaning process for larger datasets







