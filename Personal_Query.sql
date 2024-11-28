DELIMITER //

CREATE PROCEDURE QueryRecentMeal(IN user_id INT)
BEGIN
    SELECT
        buy.Bid AS UserID,
        buy.Bname AS UserName,
        bbv.Vid AS DishID,
        veg.Vname AS DishName,
        veg.Vprice AS Price,
        bbv.Bnum AS Quantity
    FROM
        bbv
    INNER JOIN buy ON bbv.Bid = buy.Bid
    INNER JOIN veg ON bbv.Vid = veg.Vid
    WHERE
        buy.Bid = user_id
    ORDER BY
        bbv.Bid DESC
    LIMIT 1; -- 最近一条购买记录
END //

CREATE PROCEDURE GetRemainingMoney(user_id INT)
BEGIN
    SELECT money
    FROM buy
    WHERE Bid = user_id;

END;
//
DELIMITER ;
