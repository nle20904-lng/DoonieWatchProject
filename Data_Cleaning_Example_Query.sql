/* ============================================================
   DoonieWatch - Data Cleaning Example (Jan-2026)
   Author: Nguyen Le

   Description:
   In my previous project, I performed data cleaning using Excel.
   In this project, I focus on cleaning and processing data using SQL.

   For demonstration purposes, I only use sales data from January 2026.
   The main objective of this project is to showcase my data cleaning
   techniques and workflow in SQL.
============================================================ */

---------------------------------------------------------------
-- View raw data
---------------------------------------------------------------
SELECT *
FROM DoonieWatch.dbo.ProductPF;


---------------------------------------------------------------
-- Remove inactive products and invalid categories
---------------------------------------------------------------
DELETE
FROM DoonieWatch.dbo.ProductPF
WHERE [Tên Phân Loại] = '-'
   OR [Tình trạng sản phẩm hiện tại] = N'Deleted';


---------------------------------------------------------------
-- Preview: Split "Category Name" into Model and Size
---------------------------------------------------------------
SELECT
    [Sản phẩm],

    SUBSTRING(
        [Tên Phân Loại],
        1,
        CHARINDEX(',', [Tên Phân Loại] + ',') - 1
    ) AS [Model],

    SUBSTRING(
        [Tên Phân Loại],
        CHARINDEX(',', [Tên Phân Loại] + ',') + 1,
        LEN([Tên Phân Loại])
    ) AS [Size]

FROM DoonieWatch.dbo.ProductPF;


---------------------------------------------------------------
-- Add new columns: Model and Size
---------------------------------------------------------------
ALTER TABLE ProductPF
ADD
    [Model] NVARCHAR(255),
    [Size]  NVARCHAR(255);


---------------------------------------------------------------
-- Populate Model and Size columns
---------------------------------------------------------------
UPDATE ProductPF
SET
    [Model] = SUBSTRING(
                  [Tên Phân Loại],
                  1,
                  CHARINDEX(',', [Tên Phân Loại] + ',') - 1
              ),

    [Size] = SUBSTRING(
                 [Tên Phân Loại],
                 CHARINDEX(',', [Tên Phân Loại] + ',') + 1,
                 LEN([Tên Phân Loại])
             );


---------------------------------------------------------------
-- Verify extracted columns
---------------------------------------------------------------
SELECT
    [Sản phẩm],
    [Model],
    [Size]
FROM DoonieWatch.dbo.ProductPF;


---------------------------------------------------------------
-- Review product names
---------------------------------------------------------------
SELECT
    [Sản phẩm],
    COUNT(*) AS Product_Count
FROM DoonieWatch.dbo.ProductPF
GROUP BY [Sản phẩm];


---------------------------------------------------------------
-- Standardize product names by brand
---------------------------------------------------------------
UPDATE ProductPF
SET
    [Sản phẩm] =
        CASE
            WHEN [Sản phẩm] LIKE N'%MVD%'     THEN 'Movado'
            WHEN [Sản phẩm] LIKE N'%A171%'    THEN N'Casio Round'
            WHEN [Sản phẩm] LIKE N'%DW%'      THEN 'DW'
            WHEN [Sản phẩm] LIKE N'%WRO6%'    THEN 'Casio'
            WHEN [Sản phẩm] LIKE N'%Pindows%' THEN 'Pindows'
            WHEN [Sản phẩm] LIKE N'%RLEX%'    THEN 'Rolex'
            ELSE [Sản phẩm]
        END;
