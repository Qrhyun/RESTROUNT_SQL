
CREATE PROCEDURE QueryRecentMeal(IN user_id INT)
BEGIN
    -- 创建临时表
    CREATE TEMPORARY TABLE IF NOT EXISTS TempRecentMeal (
        UserID INT,
        UserName VARCHAR(100),
        DishID INT,
        DishName VARCHAR(100),
        Price DECIMAL(10, 2),
        Quantity INT
    );

    -- 将查询结果插入临时表
    INSERT INTO TempRecentMeal (UserID, UserName, DishID, DishName, Price, Quantity)
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
    LIMIT 5;

END;
-- bbv表根据传入的用户 ID 查询该用户最近的 5 条购买记录



CREATE PROCEDURE GetRemainingMoney(IN user_id INT)
BEGIN
    -- 创建临时表
    CREATE TEMPORARY TABLE IF NOT EXISTS TempRemainingMoney (
        UserID INT,
        Money DECIMAL(10, 2)
    );

    -- 将查询结果插入临时表
    INSERT INTO TempRemainingMoney (UserID, Money)
    SELECT money
    FROM buy
    WHERE Bid = user_id;

    -- 选择临时表中的数据
    SELECT * FROM TempRemainingMoney;

END;










DELIMITER //


CREATE FUNCTION GetTotalSpent(IN user_id INT) RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total_spent DECIMAL(10, 2);
    SELECT SUM(veg.Vprice * bbv.Bnum) INTO total_spent
    FROM bbv
    INNER JOIN veg ON bbv.Vid = veg.Vid
    WHERE bbv.Bid = user_id;
    RETURN total_spent;
END //
DELIMITER ;


-- bbv表根据传入的用户 ID 查询并返回该用户的总消费金额，--DECIMAL(10, 2) 是一种数据类型，用于表示具有固定小数位数的精确数值。它通常用于存储货币或其他需要精确小数的数值。