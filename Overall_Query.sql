DELIMITER //

CREATE PROCEDURE `GetTop3SpendersInLast30Days`()
BEGIN
    SELECT
        buy.Bid,
        buy.Bname,
        SUM(veg.Vprice * bbv.Bnum) AS TotalSpent
    FROM
        bbv
    INNER JOIN
        buy ON bbv.Bid = buy.Bid
    INNER JOIN
        veg ON bbv.Vid = veg.Vid
    WHERE
        bbv.Btime > NOW() - INTERVAL 30 DAY
    GROUP BY
        buy.Bid,
        buy.Bname
    ORDER BY
        TotalSpent DESC
    LIMIT 3;
END//

DELIMITER ;