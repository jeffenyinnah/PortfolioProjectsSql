
  /*

Cleaning Data in SQL Queries

*/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [ProjectPortfolio].[dbo].[NashvilleHousing]

 SELECT *
 FROM NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------

-- -----------------------------------Standardize Date Format--------------------------------------------
 SELECT SaleDate, CAST(SaleDate as date)
 FROM NashvilleHousing

 ALTER TABLE NashvilleHousing ADD SaleDateConverted Date;

 UPDATE NashvilleHousing SET SaleDateConverted = CAST(SaleDate as date)

 Select SaleDateConverted from NashvilleHousing

 --ALTER TABLE NashvilleHousing DROP COLUMN SaleDate;
 
 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
SELECT * FROM NashvilleHousing
--WHERE PropertyAddress is null

-- We have a few cells of propertyAddress that are null. But when you check the ParcelID, there are duplicate parcelIDs 
-- one with PropertyAddress, other without. We need to check if ParcelID = ParcelID but different UniqueID, set the parcelID to Another
-- SOLUTION: Join the table to another

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress is null

--Update PropertyAddress with ISNULL(a.PropertyAddress, b.PropertyAddress)
UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null

SELECT * FROM NashvilleHousing

------------------------ Breaking out Address into Individual Columns (Address, City, State)----------------------------------
SELECT
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM NashvilleHousing

ALTER TABLE NashvilleHousing ADD PropertySplitAddress nvarchar(255)
ALTER TABLE NashvilleHousing ADD PropertySplitCity nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


-------------------------- Separate 'OwnerAddress' into Address, City and State using Parsename-----------------------------
SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as State,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City,
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address
FROM NashvilleHousing
WHERE OwnerAddress is not null

-- Adding new columns and updating them with owner address, city, state
ALTER TABLE NashvilleHousing ADD OwnerSplitAddress nvarchar(255)
ALTER TABLE NashvilleHousing ADD OwnerSplitCity nvarchar(255)
ALTER TABLE NashvilleHousing ADD OwnerSplitState nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT * FROM NashvilleHousing

---------------------- Change Y and N to Yes and No in "Sold as Vacant" field --------------------------------------

SELECT SoldAsVacant,
	CASE 
		WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
	END as LetSee
FROM NashvilleHousing

UPDATE NashvilleHousing --Updating the SoldAsVacant
SET SoldAsVacant = 
	CASE 
		WHEN SoldAsVacant = 'N' THEN 'No'
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
	END

SELECT * FROM NashvilleHousing

-------------------------------- Removing Duplicate ----------------------------------------------------------------
WITH RowNumber as (
	SELECT *,
		ROW_NUMBER() OVER
		(
			PARTITION BY ParcelID, PropertyAddress, SaleDate, LegalReference
			ORDER BY UniqueID
		) as row_num
	FROM NashvilleHousing
)
SELECT * -- To delete, substitute "SELECT" to "DELETE"
FROM RowNumber
WHERE row_num > 1

------------------------------ Remove unused columns----------------------------------------
ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress

SELECT * FROM NashvilleHousing
