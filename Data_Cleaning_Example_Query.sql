/* ============================================================
   DoonieWatch - Data Cleaning Example (Jan-2026)
   Author: Nguyen Le
   Description: In my previous project, I performed data cleaning using Excel. 
   In this project, I will focus on cleaning and processing the data using SQL.
	For demonstration purposes, I will only use the sales data from January 2026. 
	The main objective of this project is to showcase my data cleaning techniques and workflow in SQL.
============================================================ */
SELECT *
FROM DoonieWatch.dbo.ProductPF

-- Xóa những sản phẩm không hoạt động và những sản phẩm không có phân loại và những phần không có thông tin
Delete from ProductPF 
where [Tên Phân Loại] = '-' 
or [Tình trạng sản phẩm hiện tại] = N'Đã xóa'

-- Breaking out 'Tên phân loại' into Individual Columns ( 'Tên phân loại', 'Size')
Select 
[Sản phẩm],
Substring([Tên Phân Loại],1,Charindex(',',[Tên Phân Loại]+',') -1) as [Mẫu],
Substring([Tên Phân Loại],Charindex(',',[Tên Phân Loại]) +1,Len([Tên Phân Loại])) as [Size]
FROM DoonieWatch.dbo.ProductPF

Alter Table ProductPF
Add [Mẫu] nvarchar(255),[Size] nvarchar(255);

Update ProductPF
Set 
	[Mẫu] = Substring([Tên Phân Loại],1,Charindex(',',[Tên Phân Loại]+',') -1),
	[Size] = Substring([Tên Phân Loại],Charindex(',',[Tên Phân Loại]) +1,Len([Tên Phân Loại]));

Select 
[Sản phẩm],[Mẫu],[Size]
FROM DoonieWatch.dbo.ProductPF

-- Rút gọn tên sản phẩm theo thương hiệu
Select Distinct([Sản phẩm]),count([Sản phẩm])
FROM DoonieWatch.dbo.ProductPF
Group by [Sản phẩm]

Update ProductPF
Set 
	[Sản phẩm]= CASE
		WHEN [Sản phẩm] LIKE N'%MVD%' THEN 'Movado'
		WHEN [Sản phẩm] LIKE N'%A171%' THEN N'Casio tròn'
		WHEN [Sản phẩm] LIKE N'%DW%' THEN 'DW'
		WHEN [Sản phẩm] LIKE N'%WRO6%' THEN 'Casio'
		WHEN [Sản phẩm] LIKE N'%Pindows%' THEN 'PINDOWS'
		WHEN [Sản phẩm] LIKE N'%RLEX%' THEN 'Rolex'
		ELSE [Sản phẩm]
		END
FROM DoonieWatch.dbo.ProductPF;


