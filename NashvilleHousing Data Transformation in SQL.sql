/*
Cleaning Data in SQL Queries
In any data analysis, we identify the problem to suppport everyday business decisions and collect the data for our analysis.
This project shows the next step in the process, which is data cleaning and preparation.
In this project, the data was cleaned using SQL after importing our data from its data source.
This data is a Housing Data from the city of Nashville
--Standardize Date Format
--Populate property address data
--Populate Property address data
--Breaking out address into individaul Columns (Address, City, State)
--Splitting the address from city
--Change Y and N to Yes and No in "Sold as Vacant" field
--Delete Unused Columns
*/

Select*
From PortfolioP..NashvilleHousing

-------------------------

--Standard Date Format

Select SaleDate, CONVERT(Date, SaleDate)
From PortfolioP..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)


ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioP..NashvilleHousing

----------------------------------------------
--Populate Property Address data

Select *
From PortfolioP..NashvilleHousing
--Where PropertyAddress  is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioP..NashvilleHousing a
JOIN PortfolioP..NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
	 WHERE a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioP..NashvilleHousing a
JOIN PortfolioP..NashvilleHousing b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
	 WHERE a.PropertyAddress is null

------------------------------------------

--Breaking out Address into individaul Columns (Address, City, State)

Select PropertyAddress
From PortfolioP..NashvilleHousing
--Where PropertyAddress  is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)) as Address,
CHARINDEX(',',PropertyAddress)
From PortfolioP..NashvilleHousing

--then going one step back

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as Address
From PortfolioP..NashvilleHousing

--One step back and one step forward after','
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress)) as Address
From PortfolioP..NashvilleHousing

--Splitting the address from city

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , LEN(PropertyAddress))

Select*
From PortfolioP..NashvilleHousing

--OR

Select ownerAddress
From PortfolioP..NashvilleHousing

Select
PARSENAME(REPLACE(ownerAddress,',','.'), 3),
PARSENAME(REPLACE(ownerAddress,',','.'), 2),
PARSENAME(REPLACE(ownerAddress,',','.'), 1)
From PortfolioP..NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(ownerAddress,',','.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(ownerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(ownerAddress,',','.'), 1)

Select*
From PortfolioP..NashvilleHousing

---------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioP..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END
From PortfolioP..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 END

-----------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
Select*,
    ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				   UniqueID
				   ) row_num

From PortfolioP..NashvilleHousing
--order by ParcelID
)
Select*
--Delete
From RowNumCTE
Where row_num > 1
order by PropertyAddress

From PortfolioP..NashvilleHousing

Select*
From PortfolioP..NashvilleHousing


------------------------------------------------------------------

--Delete Unused Columns

Select*
From PortfolioP..NashvilleHousing

ALTER TABLE PortfolioP..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress

ALTER TABLE PortfolioP..NashvilleHousing
DROP COLUMN SaleDate

