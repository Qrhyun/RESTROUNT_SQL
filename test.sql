
-- 调用存储过程并传入 dish_id 为 1
CALL QueryVegPurchases(10);

-- 查看结果
SELECT * FROM TempVegPurchases;

CALL QueryRecentMeal(1);
SELECT * FROM TempRecentMeal;


CALL GetRemainingMoney(2);
SELECT * FROM TempRemainingMoney;