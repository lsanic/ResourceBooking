EXPLAIN ANALYZE 
SELECT * FROM RESERVATIONS 
WHERE resource_id = 10;

EXPLAIN ANALYZE
SELECT * FROM RESERVATIONS 
WHERE resource_id = 5 
  AND status = 'confirmed'
  AND start_time < '2026-06-15 14:00:00'::timestamp
  AND end_time > '2026-06-15 12:00:00'::timestamp;