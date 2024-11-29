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
    LIMIT 5; -- 最近一条购买记录
END //
--bbv表根据传入的用户 ID 查询该用户最近的 5 条购买记录
CREATE PROCEDURE GetRemainingMoney(user_id INT)
BEGIN

    SELECT money
    FROM buy
    WHERE Bid = user_id;

END;//

DELIMITER ;
--buy表根据传入的用户 ID 查询并返回该用户的余额


DELIMITER //

CREATE FUNCTION GetTotalSpent(user_id INT) RETURNS DECIMAL(10, 2)
BEGIN
--DECIMAL(10, 2) 是一种数据类型，用于表示具有固定小数位数的精确数值。它通常用于存储货币或其他需要精确小数的数值。
    DECLARE total_spent DECIMAL(10, 2);
    SELECT SUM(veg.Vprice * bbv.Bnum) INTO total_spent
    FROM bbv
    INNER JOIN veg ON bbv.Vid = veg.Vid
    WHERE bbv.Bid = user_id;
    RETURN total_spent;
END //

DELIMITER ;
--bbv表根据传入的用户 ID 查询并返回该用户的总消费金额