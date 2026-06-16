
CREATE OR REPLACE FUNCTION fnc_get_user_res_count (
    p_user_id INT
) 
RETURNS INT 
LANGUAGE plpgsql AS $$
DECLARE
    v_count INT := 0;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM RESERVATIONS
    WHERE user_id = p_user_id
      AND status = 'confirmed';

    RETURN v_count;
END;
$$;


-- racunam postotak iskoristenosti nekog resursa u odredenom periodu
CREATE OR REPLACE FUNCTION fnc_calculate_utilization (
    p_resource_id INT,
    p_start_date  TIMESTAMPTZ, 
    p_end_date    TIMESTAMPTZ   
) 
RETURNS NUMERIC 
LANGUAGE plpgsql AS $$
DECLARE
    v_total_hours_reserved   NUMERIC := 0;
    v_total_available_hours  NUMERIC;
    v_utilization_pct        NUMERIC := 0;
BEGIN

    SELECT COALESCE(SUM(EXTRACT(EPOCH FROM (end_time - start_time)) / 3600), 0)
    INTO v_total_hours_reserved
    FROM RESERVATIONS
    WHERE resource_id = p_resource_id
      AND status = 'confirmed'
      AND start_time >= p_start_date
      AND end_time <= p_end_date;

  
    v_total_available_hours := EXTRACT(EPOCH FROM (p_end_date - p_start_date)) / 3600;

    --- da sprijecim dijeljenje s nulom:
    IF v_total_available_hours > 0 THEN
        v_utilization_pct := (v_total_hours_reserved / v_total_available_hours) * 100;
    END IF;

    RETURN ROUND(v_utilization_pct, 2);
END;
$$;