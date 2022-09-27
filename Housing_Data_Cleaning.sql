/*

Cleaning Nashville Housing Data using SQL queries

*/

select *
from NashvilleHousing


--Making a Standard Date Format
select SaleDate, convert(date,SaleDate) as Date
from NashvilleHousing

update NashvilleHousing  --May or may not work
set SaleDate = convert(date,SaleDate)

--Alternative, adding new column with converted dates
alter table NashvilleHousing
add SaleDateC Date;

update NashvilleHousing 
set SaleDateC = convert(date,SaleDate)

select SaleDateC
from NashvilleHousing


-------------------------------------------------------------------------------------------------

--Populate Property Address Data

select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


---------------------------------------------------------------------------------------------------------------------

--Separating Addresses into its elements (Address, City, State)

--Property Address
select PropertyAddress
from NashvilleHousing

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
from NashvilleHousing

--Creating Address Column
alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing 
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

--Creating Property City column
alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing 
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))


--OwnerAddress, using PARSENAME
select OwnerAddress
from NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
, PARSENAME(REPLACE(OwnerAddress,',','.'),2)
, PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing

--Creating Owner Address column
alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing 
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

--Creating Owner City column
alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing 
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

--Creating Owner State column
alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing 
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


-----------------------------------------------------------------------------------------------------

--Change Y and N to Yes and No in SoldAsVacant column

select distinct(SoldAsVacant)
from NashvilleHousing

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from NashvilleHousing

--Updating column
update NashvilleHousing 
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

------------------------------------------------------------------------------------------------------------

--Remove Duplicates

with RowNumCTE
as(
select*
, ROW_NUMBER() over (
  partition by ParcelID,
			   PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   order by UniqueID
               ) as row_num      
from NashvilleHousing
)

--Deleting duplicate
select*
--delete
from RowNumCTE
where row_num > 1

-------------------------------------------------------------------------------------------------------------

--Removing unsed columns

alter table NashvilleHousing
drop column PropertyAddress, OwnerAddress, SaleDate