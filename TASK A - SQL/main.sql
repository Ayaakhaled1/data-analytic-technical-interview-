-- -- this common table expression is used to return events_count_percentage per user Id 
WITH cte
AS
  (
           SELECT   user_id ,
                    cast(sum(
                    CASE
                             WHEN event_type IN ('video call received',
                                                 'video call sent',
                                                 'voice call received',
                                                 'voice call sent') THEN 1
                             ELSE 0
                    end) AS FLOAT) / count(event_type) AS events_count_percentage
           FROM     fact_events
           GROUP BY user_id
           HAVING   cast(sum(
                    CASE
                             WHEN event_type IN ('video call received',
                                                 'video call sent',
                                                 'voice call received',
                                                 'voice call sent') THEN 1
                             ELSE 0
                    end) AS FLOAT) / count(event_type) >= .50 )
-- -- the following query used to return the most popular client ID based on the dense rank of number of users filtered by events_count_percentage of required list 
  SELECT     fact_events.client_id
  FROM       cte
  INNER JOIN fact_events
  ON         cte.user_id = fact_events.user_id
  GROUP BY   client_id
  ORDER BY   dense_rank() over(ORDER BY count(cte.user_id) DESC ) ASC
  LIMIT      1