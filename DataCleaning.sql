USE DataCleaning;

CREATE TABLE NashvilleHousing(
UniqueID INT,
ParcelID FLOAT,
LandUse	VARCHAR,
PropertyAddress	VARCHAR,
SaleDate DATETIME,
SalePrice INT,
LegalReference VARCHAR,
SoldAsVacant VARCHAR,
OwnerName VARCHAR,
OwnerAddress VARCHAR,
Acreage	FLOAT,
TaxDistrict	VARCHAR,
LandValue INT,
BuildingValue INT,
TotalValue INT,
YearBuilt INT,
Bedrooms INT,
FullBath INT,
HalfBath INT
);

SELECT * FROM NashvilleHousing;

-- Standardize Date Formate

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate);

--Populate Property Address date

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b 
ON a.ParcelID = b.ParcelID AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL;

-- Breaking out Address Individual  column (Area, City, State)

ALTER TABLE NashvilleHousing
ADD PropertyArea varchar, PropertyCity varchar, PropertyState varchar;

ALTER TABLE NashvilleHousing
ADD OwnerArea varchar, OwnerCity varchar, OwnerState varchar;

UPDATE NashvilleHousing
SET PropertyArea = SUBSTRING(PropertyAddress, 1, CHARINDEX(' ', PropertyAddress) - 1),
	PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(' ', PropertyAddress) +1, (CHARINDEX(' ', PropertyAddress, CHARINDEX(' ', PropertyAddress,1)+1))-(CHARINDEX(' ', PropertyAddress,1)+1)),
	PropertyState = SUBSTRING(PropertyAddress, CHARINDEX(' ', PropertyAddress, CHARINDEX(' ', PropertyAddress,1)+1), LEN(PropertyAddress)),
	OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1),
	OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2),
	OwnerArea = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

-- Change Y and N to Yes and No in "Sold as Vacant" field

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
						END;

-- Remove Duplicates

WITH duplicates AS
(
	SELECT *,
	ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
	FROM NashvilleHousing
)
DELETE FROM duplicates
WHERE row_num > 1;

--Delete Unused Columns

ALTER TABLE NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate;

SELECT * FROM NashvilleHousing;
