-- Создание таблицы уровня пользователя с информацией о просмотре страницы оплаты и оплатах

WITH table_payment AS (
    SELECT
        user_id,
        MAX(CASE WHEN page_type = 'payment' THEN 1 ELSE 0 END) AS saw_payment_page
    FROM sessions
    GROUP BY user_id
),
table_paid AS (
    SELECT
        user_id,
        1 AS paid
    FROM payments
    GROUP BY user_id
),
table_polzovateli AS (
    SELECT
        u.user_id,
        u.experiment_group,
        IFNULL(saw_payment_page,0) AS saw_payment_page,
        IFNULL(paid,0) AS paid
    FROM users u
    LEFT JOIN table_payment USING (user_id)
    LEFT JOIN table_paid USING (user_id)
)
SELECT * FROM table_polzovateli;