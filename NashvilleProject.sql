
/* Standardize Date */

Select SaleDateC, CONVERT(Date, SaleDate)
from Portfolio.dbo.Nashville

Update Nashville
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE Nashville
ADD SaleDateC Date; 

Update Nashville
SET SaleDateC = CONVERT(Date, SaleDate)


/* Populate Property Address */

Select *
From Portfolio.dbo.Nashville
--Where PropertyAddress is null
order by ParcelID

Select og.ParcelID, og.PropertyAddress, og.ParcelID, c.PropertyAddress, ISNULL(og.PropertyAddress, c.PropertyAddress)
From Portfolio.dbo.Nashville og
JOIN Portfolio.dbo.Nashville c
	on og.ParcelID = c.ParcelID
	and og.[UniqueID ] <> c.[UniqueID ]
where og.PropertyAddress is null

Update og
set PropertyAddress = ISNULL(og.PropertyAddress, c.PropertyAddress)
From Portfolio.dbo.Nashville og
JOIN Portfolio.dbo.Nashville c
	on og.ParcelID = c.ParcelID
	and og.[UniqueID ] <> c.[UniqueID ]
where og.PropertyAddress is null

/* Breaking Up Address */

Select PropertyAddress
From Portfolio.dbo.Nashville
--Where PropertyAddress is null
--order by ParcelID

 -- Removing a character from a string across an entire column --

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) Address
From Portfolio.dbo.Nashville

ALTER TABLE Nashville
ADD PropertySplitAddress NVARCHAR(255); 

Update Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE Nashville
ADD PropertySplitCity NVARCHAR(255); 

Update Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select * From Portfolio.dbo.Nashville



Select PropertyAddress
from Portfolio.dbo.Nashville

-- PARSENAME separates backwards --
Select
PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2)
, PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)
FROM Portfolio.dbo.Nashville

ALTER TABLE Nashville
ADD OwnerSplitAddress NVARCHAR(255); 

Update Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 1)

ALTER TABLE Nashville
ADD OwnerSplitCity NVARCHAR(255); 

Update Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(PropertyAddress, ',', '.'), 2)


/* Change Sold As Vacant */

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Portfolio.dbo.Nashville
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END
From Portfolio.dbo.Nashville

Update Nashville
Set SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
	   when SoldAsVacant = 'N' THEN 'No'
	   Else SoldAsVacant
	   END

/* Remove Duplicates */
--Write CTE to find where there are duplicate values --

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Portfolio.dbo.Nashville
)
Delete
From RowNumCTE
WHERE row_num > 1

Select * from Portfolio.dbo.Nashville

-- Remove PropertyAddress --
Alter Table Portfolio.dbo.Nashville
Drop Column PropertyAddress

Alter Table Portfolio.dbo.Nashville
Drop Column SaleDate, SaleDateConverted, OwnerAddress

--Remove Null --

Where [OwnerName] is null

Delete from Portfolio.dbo.Nashville
where [YearBuilt] is null

--In this case, the only other nulls are in 'Bedrooms', which I would average out in R or delete using above statements --
--HalfBath NULL we can assume it means there are no half bathrooms --
UPDATE Portfolio.dbo.Nashville SET HalfBath = 0 WHERE HalfBath is NULL






