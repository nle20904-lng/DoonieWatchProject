/* ============================================================
   DoonieWatch - Sales Performance Analysis (2025)
   Author: Nguyen Le
   Description: Some data are cleaned on Excel first
   This script performs data cleaning, aggregation, and
   exploratory analysis on e-commerce sales data.
   ============================================================ */

USE DoonieWatch;
GO


/* ============================================================
   1. Data Inspection
   ============================================================ */

SELECT *
FROM dbo.Total2025;


/* ============================================================
   2. Data Cleaning and Preprocessing
   ============================================================ */

-- Add standardized DATE column
ALTER TABLE Total2025
ADD Ngay DATE;

-- Convert string-based date into DATE format
UPDATE Total2025
SET Ngay = TRY_CONVERT(DATE, [Ngày], 103);

-- Remove inconsistent / duplicated product records
DELETE FROM dbo.DoanhThuSP2025
WHERE [Sản phẩm] = N'Đồng Hồ LNGIES Thời Trang Cặp Đôi Nam Nữ, Nhiều Màu + Mẫu Unisex, Dây Da Cá Sấu Cao Cấp, Mặt Vuông Saphiere Chống Trầy';


/* ============================================================
   3. Overall Business Performance (2025)
   ============================================================ */

SELECT 
    SUM([Tổng doanh số (VND)]) AS Total_Revenue_2025,
    SUM([Tổng số đơn hàng]) AS Total_Orders_2025,
    SUM([Đơn đã hoàn trả / hoàn tiền]) AS Total_Refunded_Orders,
    CAST(SUM([Tổng số đơn hàng]) AS FLOAT) * 100 / NULLIF(SUM([Số lượt truy cập]), 0) AS Conversion_Rate_Percent,
    CAST(SUM([Đơn đã hoàn trả / hoàn tiền]) AS FLOAT) * 100/ NULLIF(SUM([Tổng số đơn hàng]), 0) AS Refund_Rate_Percent
FROM dbo.Total2025;


/* ============================================================
   4. Monthly Conversion Performance
   ============================================================ */

SELECT
    MONTH(Ngay) AS Month,
    SUM([Tổng doanh số (VND)]) AS Monthly_Revenue,
    SUM([Tổng số đơn hàng]) AS Monthly_Orders,
    SUM([Số lượt truy cập]) AS Monthly_Traffic,
    CAST(SUM([Tổng số đơn hàng]) AS FLOAT) * 100 / NULLIF(SUM([Số lượt truy cập]), 0) AS Monthly_Conversion_Rate
FROM dbo.Total2025
GROUP BY MONTH(Ngay)
ORDER BY Month;

/* ============================================================
   5. Product-Level Performance Analysis
   ============================================================ */

-- Overall product contribution
SELECT
    [Sản phẩm] AS Product_Name,
    SUM([Doanh Số]) AS Total_Revenue,
    SUM([Sản phẩm1]) AS Total_Units_Sold
FROM dbo.DoanhThuSP2025
GROUP BY [Sản phẩm]
ORDER BY Total_Revenue DESC;


-- Monthly product performance
SELECT 
    MONTH([Tháng]) AS Month, 
    [Sản phẩm] AS Product_Name,
    SUM([Doanh Số]) AS Monthly_Revenue,
    SUM([Sản phẩm1]) AS Units_Sold
FROM dbo.DoanhThuSP2025
GROUP BY MONTH([Tháng]), [Sản phẩm]
ORDER BY Month, Monthly_Revenue DESC;


/* ============================================================
   6. Top-Selling Product by Month
   ============================================================ */

WITH MonthlyProductSales AS (
    SELECT 
        MONTH([Tháng]) AS Month,
        [Sản phẩm] AS Product_Name,
        SUM([Sản phẩm1]) AS Total_Units_Sold
    FROM dbo.DoanhThuSP2025
    GROUP BY MONTH([Tháng]), [Sản phẩm]
),

RankedProducts AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY Month
            ORDER BY Total_Units_Sold DESC
        ) AS Ranking
    FROM MonthlyProductSales
)

SELECT
    Month,
    Product_Name,
    Total_Units_Sold
FROM RankedProducts
WHERE Ranking = 1
ORDER BY Month;


/* ============================================================
   7. Refund Analysis
   ============================================================ */

SELECT 
    MONTH(Ngay) AS Month,
    SUM([Tổng số đơn hàng]) AS Total_Orders,
    SUM([Đơn đã hoàn trả / hoàn tiền]) AS Refunded_Orders,
    CAST(SUM([Đơn đã hoàn trả / hoàn tiền]) AS FLOAT) * 100 / NULLIF(SUM([Tổng số đơn hàng]), 0) AS Refund_Rate_Percent
FROM dbo.Total2025
GROUP BY MONTH(Ngay)
ORDER BY Refund_Rate_Percent DESC;


/* ============================================================
   8. Order Cancellation Analysis
   ============================================================ */

SELECT
    MONTH(Ngay) AS Month,
    SUM([Tổng số đơn hàng]) AS Total_Orders,
    SUM([Đơn đã hủy]) AS Canceled_Orders,
    CAST(SUM([Đơn đã hủy]) AS FLOAT) * 100 / NULLIF(SUM([Tổng số đơn hàng]), 0) AS Cancellation_Rate_Percent
FROM dbo.Total2025
GROUP BY MONTH(Ngay)
ORDER BY Cancellation_Rate_Percent DESC;


/* ============================================================
   9. Monthly Revenue Analysis
   ============================================================ */

SELECT
    MONTH(Ngay) AS Month,
    SUM([Tổng doanh số (VND)]) AS Monthly_Revenue,
    SUM([Tổng số đơn hàng]) AS Monthly_Orders,
    SUM([Số lượt truy cập]) AS Monthly_Visits,
    CAST(SUM([Tổng số đơn hàng]) AS FLOAT) * 100 / NULLIF(SUM([Số lượt truy cập]), 0) AS Conversion_Rate
FROM dbo.Total2025
GROUP BY MONTH(Ngay)
ORDER BY Monthly_Revenue DESC;


/* ============================================================
   10. Best and Worst Performing Months (Revenue)
   ============================================================ */

-- Top 3 highest revenue months
SELECT TOP 3
    YEAR(Ngay) AS Year,
    MONTH(Ngay) AS Month,
    SUM([Tổng doanh số (VND)]) AS Total_Revenue
FROM dbo.Total2025
GROUP BY YEAR(Ngay), MONTH(Ngay)
ORDER BY Total_Revenue DESC;


-- Top 3 lowest revenue months
SELECT TOP 3
    YEAR(Ngay) AS Year,
    MONTH(Ngay) AS Month,
    SUM([Tổng doanh số (VND)]) AS Total_Revenue
FROM dbo.Total2025
GROUP BY YEAR(Ngay), MONTH(Ngay)
ORDER BY Total_Revenue ASC;


/* ============================================================
   11. Sales Funnel and Drop-off Analysis
   ============================================================ */

SELECT  
    MONTH(Ngay) AS Month,
    SUM([Số lượt truy cập]) AS Total_Traffic,
    SUM([Tổng số đơn hàng]) AS Total_Orders,
    CAST(SUM([Lượt nhấp vào sản phẩm]) AS FLOAT) * 100 / NULLIF(SUM([Số lượt truy cập]), 0) AS CTR_Percent,
    CAST(SUM([Tổng số đơn hàng]) AS FLOAT) * 100 / NULLIF(SUM([Số lượt truy cập]), 0) AS Conversion_Rate_Percent,
    -- Problem Score: Visits per Order (higher = worse performance)
    CAST(SUM([Số lượt truy cập]) AS FLOAT) / NULLIF(SUM([Tổng số đơn hàng]), 0) AS Problem_Score
FROM dbo.Total2025
GROUP BY MONTH(Ngay)
ORDER BY Problem_Score DESC;
