DELIMITER //

CREATE PROCEDURE CreateWindowViews()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE current_wid INT;
    DECLARE current_wadd INT;
    DECLARE cur CURSOR FOR SELECT Wid, Wadd FROM win;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- 打开游标
    OPEN cur;

    fetch_loop: LOOP
        FETCH cur INTO current_wid, current_wadd;

        IF done THEN
            LEAVE fetch_loop;
        END IF;

        -- 动态创建视图的 SQL
        SET @view_name = CONCAT('floor_', current_wadd, '_', current_wid);
        SET @create_view_sql = CONCAT(
            'CREATE OR REPLACE VIEW ', @view_name, ' AS ',
            'SELECT veg.Vid, veg.Vname, veg.Vprice, ',
            'GROUP_CONCAT(DISTINCT cook.Cname ORDER BY cook.Cname SEPARATOR \', \') AS CookNames ',
            'FROM whv ',
            'INNER JOIN veg ON whv.Vid = veg.Vid ',
            'INNER JOIN cmv ON cmv.Vid = veg.Vid ',
            'INNER JOIN cook ON cmv.Cid = cook.Cid ',
            'WHERE whv.Wid = ', current_wid, ' ',
            'GROUP BY veg.Vid, veg.Vname, veg.Vprice'
        );

        -- 执行动态 SQL 创建视图
        PREPARE stmt FROM @create_view_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

    END LOOP;

    -- 关闭游标
    CLOSE cur;
END //

DELIMITER ;

--根据 win 表中的数据动态创建多个视图，每个视图包含与特定窗口相关的菜品及其对应的厨师信息。
DELIMITER //

CREATE PROCEDURE QueryVegPurchases(IN dish_id INT)
BEGIN
    SELECT
        bbv.Vid AS DishID,
        veg.Vname AS DishName,
        buy.Bid AS UserID,
        buy.Bname AS UserName,
        bbv.Bnum AS Quantity,
        bbv.Btime AS PurchaseDate
    
    FROM
        bbv
    INNER JOIN veg ON bbv.Vid = veg.Vid
    INNER JOIN buy ON bbv.Bid = buy.Bid
    WHERE
        bbv.Vid = dish_id
    ORDER BY
        bbv.Btime DESC;
END //

DELIMITER ;
--根据传入的菜品 ID 查询所有窗口的该菜品的所有购买记录，并返回相关信息，包括菜品 ID、菜品名称、用户 ID、用户名、购买数量和购买日期。通过调用这个存储过程，后端可以方便地获取指定菜品的购买记录。


DELIMITER //

CREATE PROCEDURE CreateWindowVegPurchaseViews()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE current_wid INT;
    DECLARE current_wadd INT;
    DECLARE cur CURSOR FOR SELECT Wid, Wadd FROM win;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    -- 打开游标
    OPEN cur;

    fetch_loop: LOOP
        FETCH cur INTO current_wid, current_wadd;

        IF done THEN
            LEAVE fetch_loop;
        END IF;

        -- 动态创建视图的 SQL
        SET @view_name = CONCAT('window_', current_wadd, '_', current_wid, '_dish_purchases');
        SET @create_view_sql = CONCAT(
            'CREATE OR REPLACE VIEW ', @view_name, ' AS ',
            'SELECT veg.Vid AS DishID, veg.Vname AS DishName, ',
            'buy.Bid AS UserID, buy.Bname AS UserName, ',
            'bbv.Bnum AS Quantity, bbv.Bdate AS PurchaseDate ',
            'FROM bbv ',
            'INNER JOIN veg ON bbv.Vid = veg.Vid ',
            'INNER JOIN buy ON bbv.Bid = buy.Bid ',
            'INNER JOIN whv ON whv.Vid = veg.Vid ',
            'WHERE whv.Wid = ', current_wid, ' ',
            'AND DATE(bbv.Bdate) = CURDATE() ', -- 限制为当天的记录
            'ORDER BY bbv.Bdate DESC'
        );

        -- 执行动态 SQL 创建视图
        PREPARE stmt FROM @create_view_sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;

    END LOOP;

    -- 关闭游标
    CLOSE cur;
END //

DELIMITER ;
--动态创建视图，每个视图包含某个窗口的每个菜品在同一天的购买记录