SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM usage_metrics;

SELECT COUNT(*) FROM subscription_status;





SELECT 
    COUNT(*) AS total_users,
    SUM(churned) AS churned_users,
    ROUND(SUM(churned) * 100.0 / COUNT(*), 2) AS churn_rate_percent
FROM subscription_status;



SELECT 
    SUM(monthly_price * (1 - discount_percent/100.0)) AS current_mrr
FROM subscription_status
WHERE churned = 0;


SELECT 
    u.plan_type,
    COUNT(*) AS total_users,
    SUM(s.churned) AS churned_users,
    ROUND(SUM(s.churned)*100.0/COUNT(*),2) AS churn_rate_percent
FROM users u
JOIN subscription_status s ON u.user_id = s.user_id
GROUP BY u.plan_type
ORDER BY churn_rate_percent DESC;



SELECT 
    u.acquisition_channel,
    COUNT(*) AS total_users,
    SUM(s.churned) AS churned_users,
    ROUND(SUM(s.churned)*100.0/COUNT(*),2) AS churn_rate_percent
FROM users u
JOIN subscription_status s ON u.user_id = s.user_id
GROUP BY u.acquisition_channel
ORDER BY churn_rate_percent DESC;



SELECT 
    u.plan_type,
    SUM(CASE WHEN s.churned = 1 
        THEN s.monthly_price * (1 - s.discount_percent/100.0)
        ELSE 0 END) AS revenue_lost
FROM users u
JOIN subscription_status s ON u.user_id = s.user_id
GROUP BY u.plan_type
ORDER BY revenue_lost DESC;


select u.plan_type,
sum(
	case
		when s.churned = 1
        then s.monthly_price * (1 - s.discount_percent/100.0)
        else 0
	end
) as revenue_lost

from users u join subscription_status s on u.user_id = s.user_id
group by u.plan_type
order by revenue_lost Desc;


SELECT 
    CASE 
        WHEN avg_weekly_logins <= 1 THEN 'Low'
        WHEN avg_weekly_logins <= 3 THEN 'Medium'
        ELSE 'High'
    END AS engagement_segment,
    COUNT(*) AS total_users,
    SUM(s.churned) AS churned_users,
    ROUND(SUM(s.churned)*100.0/COUNT(*),2) AS churn_rate_percent
FROM usage_metrics u
JOIN subscription_status s ON u.user_id = s.user_id
GROUP BY engagement_segment
ORDER BY churn_rate_percent DESC;


SELECT 
    u.plan_type,
    CASE 
        WHEN m.avg_weekly_logins <= 1 THEN 'Low'
        WHEN m.avg_weekly_logins <= 3 THEN 'Medium'
        ELSE 'High'
    END AS engagement_segment,
    COUNT(*) AS total_users,
    SUM(s.churned) AS churned_users,
    ROUND(SUM(s.churned) * 100.0 / COUNT(*), 2) AS churn_rate
FROM users u
JOIN subscription_status s ON u.user_id = s.user_id
JOIN usage_metrics m ON u.user_id = m.user_id
GROUP BY u.plan_type, engagement_segment
ORDER BY churn_rate DESC;


-- Calculates churn-driven revenue loss and its percentage contribution by engagement segment

SELECT 
    CASE 
        WHEN m.avg_weekly_logins <= 1 THEN 'Low'
        WHEN m.avg_weekly_logins <= 3 THEN 'Medium'
        ELSE 'High'
    END AS engagement_segment,
    
    SUM(
        CASE 
            WHEN s.churned = 1 
            THEN s.monthly_price * (1 - s.discount_percent/100.0)
            ELSE 0 
        END
    ) AS revenue_lost,
    
    ROUND(
        SUM(
            CASE 
                WHEN s.churned = 1 
                THEN s.monthly_price * (1 - s.discount_percent/100.0)
                ELSE 0 
            END
        ) * 100.0 /
        (
            SELECT SUM(
                CASE 
                    WHEN churned = 1 
                    THEN monthly_price * (1 - discount_percent/100.0)
                    ELSE 0 
                END
            )
            FROM subscription_status
        ),
        2
    ) AS percent_of_total_loss

FROM usage_metrics m
JOIN subscription_status s ON m.user_id = s.user_id
GROUP BY engagement_segment
ORDER BY revenue_lost DESC;

-- Are Pro users dominating the Medium engagement segment?
SELECT 
    u.plan_type,
    COUNT(*) AS total_users,
    SUM(
        CASE 
            WHEN s.churned = 1 
            THEN s.monthly_price * (1 - s.discount_percent/100.0)
            ELSE 0 
        END
    ) AS revenue_lost
FROM users u
JOIN subscription_status s ON u.user_id = s.user_id
JOIN usage_metrics m ON u.user_id = m.user_id
WHERE m.avg_weekly_logins BETWEEN 2 AND 3
GROUP BY u.plan_type
ORDER BY revenue_lost DESC;

