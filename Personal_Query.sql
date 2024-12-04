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
-- bbv表根据传入的用户 ID 查询该用户最近的 5 条购买记录
CREATE PROCEDURE GetRemainingMoney(user_id INT)
BEGIN

    SELECT money
    FROM buy
    WHERE Bid = user_id;

END;//

DELIMITER ;
-- buy表根据传入的用户 ID 查询并返回该用户的余额


DELIMITER //


CREATE FUNCTION GetTotalSpent(user_id INT) RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
    DECLARE total_spent DECIMAL(10, 2);
    SELECT SUM(veg.Vprice * bbv.Bnum) INTO total_spent
    FROM bbv
    INNER JOIN veg ON bbv.Vid = veg.Vid
    WHERE bbv.Bid = user_id;
    RETURN total_spent;
END;
//
DELIMITER ;


-- bbv表根据传入的用户 ID 查询并返回该用户的总消费金额，--DECIMAL(10, 2) 是一种数据类型，用于表示具有固定小数位数的精确数值。它通常用于存储货币或其他需要精确小数的数值。

DELIMITER //

DROP PROCEDURE IF EXISTS GetTop5VegByRemark;
CREATE PROCEDURE GetTop5VegByRemark()
BEGIN
    SELECT
        Vid AS DishID,
        Vname AS DishName,
        Vprice AS Price,
        sale AS Sales,
        Vremark AS Remark
    FROM
        veg
    ORDER BY
        Vremark DESC
    LIMIT 5;
END //

DELIMITER ;
DELIMITER //

CREATE PROCEDURE DineInProcess(
    IN input_Bid INT,    -- 消费者ID
    IN input_Vid INT,    -- 菜品ID
    IN input_Bnum INT    -- 点餐数量
)
BEGIN
    -- 声明变量
    DECLARE dish_price DECIMAL(10, 2);
    DECLARE total_cost DECIMAL(10, 2);
    DECLARE consumer_money DECIMAL(10, 2);
    DECLARE rows_affected INT;

    -- 检查消费者是否存在
    IF NOT EXISTS (SELECT 1 FROM buy WHERE Bid = input_Bid) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Consumer does not exist.';
    END IF;

    -- 检查菜品是否存在
    IF NOT EXISTS (SELECT 1 FROM veg WHERE Vid = input_Vid) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Dish does not exist.';
    END IF;

    -- 开始事务
    START TRANSACTION;

    -- 获取菜品价格
    SELECT Vprice INTO dish_price FROM veg WHERE Vid = input_Vid;

    -- 计算总花费
    SET total_cost = dish_price * input_Bnum;

    -- 检查消费者余额是否充足
    SELECT money INTO consumer_money FROM buy WHERE Bid = input_Bid;

    IF consumer_money < total_cost THEN
        -- 如果余额不足，回滚事务
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient balance.';
    ELSE
        -- 插入点餐信息到bbv表，使用CURRENT_TIMESTAMP作为点餐时间
        INSERT INTO bbv (Bid, Vid, Bnum, Btime) VALUES (input_Bid, input_Vid, input_Bnum, CURRENT_TIMESTAMP);
        -- 获取插入影响的行数
        SET rows_affected = ROW_COUNT();

        IF rows_affected > 0 THEN
            -- 如果插入成功，打印插入的行
            SELECT 'Inserted row: ', input_Bid, input_Vid, input_Bnum, CURRENT_TIMESTAMP;
            -- 更新消费者余额
            UPDATE buy SET money = money - total_cost WHERE Bid = input_Bid;
            -- 提交事务
            COMMIT;
        ELSE
            -- 如果插入失败，回滚事务并返回NULL
            ROLLBACK;
            SELECT NULL;
        END IF;
    END IF;
END//

DELIMITER ;

DELIMITER ;