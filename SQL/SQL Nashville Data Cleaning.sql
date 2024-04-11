SELECT *
FROM SQLPortfolioProject.dbo.NashvilleHousing

-- Standardize Date Format
SELECT SaleDate
FROM SQLPortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT TOP 5*
FROM SQLPortfolioProject.dbo.NashvilleHousing

--Populate Property Address data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM SQLPortfolioProject.dbo.NashvilleHousing a
JOIN SQLPortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
