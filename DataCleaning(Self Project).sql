
--Cleaning Data in SQL--

SELECT *
FROM DataCleaning..Nashvil


----------------------------------------------------------------------

--Changing SaleDate Format--

SELECT CAST(SaleDate AS Date) as SaleDate
FROM DataCleaning..

UPDATE Nashvil
SET SaleDate = CAST(SaleDate AS Date)

ALTER TABLE Nashvil 
ALTER COLUMN SaleDate DATE

----------------------------------------------------------------------

--Property Address Data (Adding the address to the null values based on the ParcelID)
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning..Nashvil a
JOIN DataCleaning..Nashvil b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM DataCleaning..Nashvil a
JOIN DataCleaning..Nashvil b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] != b.[UniqueID ]

--Breaking PropertyAddress into individual Columns (Address, City)

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
	  , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM DataCleaning..Nashvil

ALTER TABLE Nashvil
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Nashvil
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashvil
ADD PropertySplitCity NVARCHAR(255);

UPDATE Nashvil
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))


--Breaking OwnerAddress into individual Columns (Address, City, State)

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS Address, 
	   PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS City,
	   PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS State
FROM DataCleaning..Nashvil

ALTER TABLE Nashvil
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Nashvil
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashvil
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Nashvil
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashvil
ADD OwnerSplitState NVARCHAR(255);

UPDATE Nashvil
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Change Y and N to Yes and No for SoldASVacant

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM DataCleaning..Nashvil
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM DataCleaning..Nashvil

UPDATE Nashvil
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--Removing Duplicates

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				LegalReference
				ORDER BY
					UniqueID
					) row_num
FROM DataCleaning..Nashvil

)
DELETE  
FROM RowNumCTE
WHERE row_num > 1


--Delete Unused Columns

SELECT *
FROM DataCleaning..Nashvil

ALTER TABLE DataCleaning..Nashvil
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate