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


