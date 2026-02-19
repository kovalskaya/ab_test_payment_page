-- Расчёт основных метрик по группам эксперимента
-- Комментарии начинаются с --

WITH table_payment AS (
    SELECT
        user_id,
        MAX(CASE WHEN page_type = 'payment' THEN 1 ELSE 0 END) AS saw_payment_page
        -- saw_payment_page = 1, если пользователь видел страницу оплаты, иначе 0
    FROM sessions
    GROUP BY user_id
),
table_paid AS (
    SELECT
        user_id,
        1 AS paid
        -- paid = 1, если пользователь совершил оплату
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

SELECT
    experiment_group,

    COUNT(user_id) AS users_total,
    -- users_total = общее количество пользователей в группе

    SUM(saw_payment_page) AS users_saw_payment,
    -- users_saw_payment = сколько пользователей дошли до страницы оплаты

    SUM(paid) AS users_paid,
    -- users_paid = сколько пользователей оплатили

    SUM(saw_payment_page)*1.0/COUNT(user_id) AS cr_to_payment_page,
    -- cr_to_payment_page = конверсия пользователей, которые дошли до страницы оплаты (CR до страницы оплаты)

    SUM(paid)*1.0/COUNT(user_id) AS cr_total_to_paid,
    -- cr_total_to_paid = конверсия всех пользователей в оплату (ITT)

    SUM(paid)*1.0/NULLIF(SUM(saw_payment_page),0) AS cr_page_to_paid,
    -- cr_page_to_paid = конверсия из пользователей, увидевших страницу оплаты, в оплативших (CR страницы оплаты)

    1 - SUM(paid)*1.0/NULLIF(SUM(saw_payment_page),0) AS drop_after_payment_page,
    -- drop_after_payment_page = доля пользователей, которые увидели страницу оплаты, но не оплатили

    SUM(amount)/NULLIF(SUM(paid),0) AS aov,
    -- aov = средний чек (Average Order Value)

    SUM(amount) AS revenue,
    -- revenue = общая выручка

    SUM(amount)*1.0/COUNT(user_id) AS arpu
    -- arpu = средняя выручка на пользователя (Average Revenue Per User)

FROM table_polzovateli tp
LEFT JOIN payments pay USING (user_id)
GROUP BY experiment_group;
