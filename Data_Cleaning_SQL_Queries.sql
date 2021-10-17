SELECT * 
from [Housing Data]..Housing_data_file


--Standardize sale date

--SELECT SaleDate, CONVERT(date,SaleDate)
--from [Housing Data]..Housing_data_file

--Update Housing_data_file
--SET SaleDate = CONVERT(date,SaleDate)


ALTER TABLE [Housing Data]..Housing_data_file
ADD SaleDateConverted Date

Update [Housing Data]..Housing_data_file
SET SaleDateConverted = CONVERT(date,SaleDate)

SELECT *
from [Housing Data]..Housing_data_file



--Populate Property Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Housing Data]..Housing_data_file a
JOIN [Housing Data]..Housing_data_file b
 ON a.ParcelID = b.ParcelID
 AND a.UniqueID <> b.UniqueID
where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Housing Data]..Housing_data_file a
JOIN [Housing Data]..Housing_data_file b
 ON a.ParcelID = b.ParcelID
 AND a.UniqueID <> b.UniqueID
 where a.PropertyAddress is null




 --Breaking out Address into individual columns
 
 SELECT PropertyAddress
 FROM [Housing Data]..Housing_data_file

 
 SELECT 
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as City
 FROM [Housing Data]..Housing_data_file


 ALTER TABLE [Housing Data]..Housing_data_file
 ADD PropertySplitAddress nvarchar(255);

 UPDATE [Housing Data]..Housing_data_file
 SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)
 
 ALTER TABLE [Housing Data]..Housing_data_file
 ADD PropertySplitCity nvarchar(255)

 UPDATE [Housing Data]..Housing_data_file
 SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


 --OwnerAddress

 SELECT OwnerAddress
 FROM [Housing Data]..Housing_data_file

 SELECT 
 PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
 PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
 PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
 FROM [Housing Data]..Housing_data_file

 ALTER TABLE [Housing Data]..Housing_data_file
 ADD Owner_Address nvarchar(255)

 UPDATE [Housing Data]..Housing_data_file
 SET Owner_Address= PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

 ALTER TABLE [Housing Data]..Housing_data_file
 ADD Owner_Address_City nvarchar(255)

 UPDATE [Housing Data]..Housing_data_file
 SET Owner_Address_City= PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

 ALTER TABLE [Housing Data]..Housing_data_file
 ADD Owner_Address_State nvarchar(255)

 UPDATE [Housing Data]..Housing_data_file
 SET Owner_Address_State= PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

 SELECT *
 FROM [Housing Data]..Housing_data_file




 --Change Y and N from Yes and No in SoldASVacant field

 SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
 FROM [Housing Data]..Housing_data_file
 GROUP BY SoldAsVacant


 SELECT SoldAsVacant,
 CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
 FROM [Housing Data]..Housing_data_file


 UPDATE [Housing Data]..Housing_data_file
 SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
      WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END



--Remove Duplicates

SELECT *
FROM [Housing Data]..Housing_data_file



WITH RowCTE AS (
SELECT *, 
       ROW_NUMBER() OVER (
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
					 UniqueID
					 ) row_num

FROM [Housing Data]..Housing_data_file
)
DELETE
FROM RowCTE
WHERE row_num > 1


--SELECT *
--FROM RowCTE
--WHERE row_num > 1




--DELETE Unused Columns

SELECT *
FROM [Housing Data]..Housing_data_file

ALTER TABLE [Housing Data]..Housing_data_file
DROP COLUMN OwnerAddress, PropertyAddress