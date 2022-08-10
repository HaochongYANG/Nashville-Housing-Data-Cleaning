/*

Cleaning Data In SQL Queries

*/

USE sql_nashville_housing;

SELECT *
FROM nashville_housing;

-- Standardize Date Format --

SELECT SaleDate, CONVERT(SaleDate, DATE)
FROM nashville_housing;

ALTER TABLE nashville_housing
MODIFY SaleDateConverted DATE;

UPDATE nashville_housing
SET SaleDateConverted = CONVERT(SaleDate, DATE);

-- Populate Property Address Data --

SELECT *
FROM nashville_housing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashville_housing a
JOIN nashville_housing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL;

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress);

-- Breaking out Address into Individual Columns (Address, City, State) --

SELECT PropertyAddress
FROM nashville_housing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID;

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address

FROM nashville_housing;

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 );

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress));

SELECT *
FROM nashville_housing;

SELECT OwnerAddress
FROM nashville_housing;

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM nashville_housing;

ALTER TABLE nashville_housing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE nashville_housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3);

ALTER TABLE nashville_housing
ADD OwnerSplitCity Nvarchar(255);

UPDATE nashville_housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2);

ALTER TABLE nashville_housing
ADD OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1);

Select *
From nashville_housing;

-- Change Y and N to Yes and No in "Sold as Vacant" field --

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From nashville_housing;

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;

-- Remove Duplicates --

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() 
		OVER ( PARTITION BY ParcelID, PropertyAddress, 
							SalePrice, SaleDate, LegalReference 
		       ORDER BY UniqueID
			  ) row_num

FROM nashville_housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

SELECT *
FROM nashville_housing;

-- Delete Unused Columns --

ALTER TABLE nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate;