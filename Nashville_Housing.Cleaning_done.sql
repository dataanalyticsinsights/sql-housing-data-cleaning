USE PortfolioProject;

SET SQL_SAFE_UPDATES = 0;

-- =====================================================
-- Step 0: Check raw data
-- =====================================================

SELECT *
FROM housing
LIMIT 20;


-- =====================================================
-- Step 1: Convert SaleDate to proper date format
-- Original format: MM/DD/YYYY
-- =====================================================

ALTER TABLE housing
ADD COLUMN SaleDateConverted DATE;

UPDATE housing
SET SaleDateConverted = STR_TO_DATE(SaleDate, '%m/%d/%Y');

SELECT SaleDate, SaleDateConverted
FROM housing
LIMIT 10;


-- =====================================================
-- Step 2: Check missing PropertyAddress
-- =====================================================

SELECT *
FROM housing
WHERE PropertyAddress IS NULL;


-- =====================================================
-- Step 3: Fill missing PropertyAddress using ParcelID
-- =====================================================

UPDATE housing a
JOIN housing b
    ON a.ParcelID = b.ParcelID
   AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress IS NULL
  AND b.PropertyAddress IS NOT NULL;

SELECT *
FROM housing
WHERE PropertyAddress IS NULL;


-- =====================================================
-- Step 4: Split PropertyAddress into address and city
-- =====================================================

ALTER TABLE housing
ADD COLUMN PropertySplitAddress VARCHAR(255);

ALTER TABLE housing
ADD COLUMN PropertySplitCity VARCHAR(255);

UPDATE housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1);

UPDATE housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1);

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM housing
LIMIT 10;


-- =====================================================
-- Step 5: Split OwnerAddress into address, city, state
-- =====================================================

ALTER TABLE housing
ADD COLUMN OwnerSplitAddress VARCHAR(255);

ALTER TABLE housing
ADD COLUMN OwnerSplitCity VARCHAR(255);

ALTER TABLE housing
ADD COLUMN OwnerSplitState VARCHAR(255);

UPDATE housing
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

UPDATE housing
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

UPDATE housing
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM housing
LIMIT 10;


-- =====================================================
-- Step 6: Standardize SoldAsVacant
-- =====================================================

SELECT SoldAsVacant, COUNT(*) AS total
FROM housing
GROUP BY SoldAsVacant;

UPDATE housing
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
    WHEN SoldAsVacant = 'N' THEN 'No'
    ELSE SoldAsVacant
END;

SELECT SoldAsVacant, COUNT(*) AS total
FROM housing
GROUP BY SoldAsVacant;


-- =====================================================
-- Step 7: Trim spaces
-- =====================================================

UPDATE housing
SET 
    PropertySplitAddress = TRIM(PropertySplitAddress),
    PropertySplitCity = TRIM(PropertySplitCity),
    OwnerSplitAddress = TRIM(OwnerSplitAddress),
    OwnerSplitCity = TRIM(OwnerSplitCity),
    OwnerSplitState = TRIM(OwnerSplitState);

-- Remove double spaces inside addresses
UPDATE housing
SET 
    PropertySplitAddress = REPLACE(PropertySplitAddress, '  ', ' '),
    OwnerSplitAddress = REPLACE(OwnerSplitAddress, '  ', ' ');

-- Run this again in case there are still double spaces
UPDATE housing
SET 
    PropertySplitAddress = REPLACE(PropertySplitAddress, '  ', ' '),
    OwnerSplitAddress = REPLACE(OwnerSplitAddress, '  ', ' ');

SELECT 
    PropertySplitAddress,
    OwnerSplitAddress
FROM housing
WHERE PropertySplitAddress LIKE '%  %'
   OR OwnerSplitAddress LIKE '%  %'
LIMIT 20;


-- =====================================================
-- Step 8: Check duplicate rows
-- =====================================================

SELECT 
    ParcelID,
    SalePrice,
    SaleDateConverted,
    LegalReference,
    COUNT(*) AS duplicate_count
FROM housing
GROUP BY 
    ParcelID,
    SalePrice,
    SaleDateConverted,
    LegalReference
HAVING COUNT(*) > 1;


-- =====================================================
-- Step 9: Create final clean view
-- This removes duplicates logically using ROW_NUMBER()
-- It also gives better column names
-- =====================================================

DROP VIEW IF EXISTS housing_final;

CREATE VIEW housing_final AS
SELECT
    UniqueID AS unique_id,
    ParcelID AS parcel_id,
    LandUse AS land_use,
    SalePrice AS sale_price,
    SaleDateConverted AS sale_date,
    LegalReference AS legal_reference,
    SoldAsVacant AS sold_as_vacant,
    PropertySplitAddress AS property_address,
    PropertySplitCity AS property_city,
    OwnerSplitAddress AS owner_address,
    OwnerSplitCity AS owner_city,
    OwnerSplitState AS owner_state,
    Acreage AS acreage,
    TaxDistrict AS tax_district,
    LandValue AS land_value,
    BuildingValue AS building_value,
    TotalValue AS total_value,
    YearBuilt AS year_built,
    Bedrooms AS bedrooms,
    FullBath AS full_bath,
    HalfBath AS half_bath
FROM (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, SalePrice, SaleDateConverted, LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM housing
) t
WHERE row_num = 1;


-- =====================================================
-- Step 10: Check final clean data
-- =====================================================

SELECT *
FROM housing_final
LIMIT 20;


-- =====================================================
-- Step 11: Confirm duplicates are removed in final view
-- =====================================================

SELECT 
    parcel_id,
    sale_price,
    sale_date,
    legal_reference,
    COUNT(*) AS duplicate_count
FROM housing_final
GROUP BY 
    parcel_id,
    sale_price,
    sale_date,
    legal_reference
HAVING COUNT(*) > 1;


-- =====================================================
-- Step 12: Sort by sale date
-- =====================================================

SELECT *
FROM housing_final
ORDER BY sale_date ASC
LIMIT 20;

SELECT *
FROM housing_final
ORDER BY sale_date DESC
LIMIT 20;


-- =====================================================
-- Step 13: Check owner address vs property address
-- Not always an error. Owner may live somewhere else.
-- =====================================================

SELECT *
FROM housing_final
WHERE property_address <> owner_address
LIMIT 20;


-- =====================================================
-- Step 14: Simple analysis queries
-- =====================================================

-- Average sale price by city
SELECT 
    property_city,
    AVG(sale_price) AS avg_sale_price
FROM housing_final
GROUP BY property_city
ORDER BY avg_sale_price DESC;

-- Count of vacant vs not vacant
SELECT 
    sold_as_vacant,
    COUNT(*) AS total
FROM housing_final
GROUP BY sold_as_vacant;

-- Average sale price by bedrooms
SELECT 
    bedrooms,
    AVG(sale_price) AS avg_sale_price
FROM housing_final
GROUP BY bedrooms
ORDER BY bedrooms;

SELECT *
FROM housing_final;