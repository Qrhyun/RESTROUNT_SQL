
-- ���ô洢���̲����� dish_id Ϊ 1
CALL QueryVegPurchases(10);

-- �鿴���
SELECT * FROM TempVegPurchases;

CALL QueryRecentMeal(1);
SELECT * FROM TempRecentMeal;


CALL GetRemainingMoney(2);
SELECT * FROM TempRemainingMoney;