
CREATE OR REPLACE PROCEDURE prc_reserve_resource (
    p_user_id      INT,
    p_resource_id  INT,
    p_start_time   TIMESTAMP,
    p_end_time     TIMESTAMP,
    p_purpose      VARCHAR DEFAULT NULL
)

LANGUAGE plpgsql AS $$
DECLARE
    v_resource_status  RESOURCES.status%TYPE;
    v_overlap_count    INT;
BEGIN
    -- zakljucavam resurse radi sprječavanja race conditiona
    SELECT status INTO v_resource_status
    FROM RESOURCES
    WHERE resource_id = p_resource_id
    FOR UPDATE;

   
    IF v_resource_status IS NULL THEN
        RAISE EXCEPTION 'Greška: Resurs s ID-jem % ne postoji.', p_resource_id USING ERRCODE = 'P0003';
    END IF;

    IF v_resource_status != 'available' THEN
        RAISE EXCEPTION 'Resurs nije dostupan. Status: %', v_resource_status USING ERRCODE = 'P0001';
    END IF;

    -- provjeravam preklapanje termina:
    SELECT COUNT(*)
    INTO v_overlap_count
    FROM RESERVATIONS
    WHERE resource_id = p_resource_id
      AND status = 'confirmed'
      AND (p_start_time < end_time AND p_end_time > start_time);

    IF v_overlap_count > 0 THEN
        RAISE EXCEPTION 'Termin je zauzet! Resurs je već rezerviran.' USING ERRCODE = 'P0002';
    END IF;

    INSERT INTO RESERVATIONS (
        user_id, resource_id, start_time, end_time, status, purpose
    ) VALUES (
        p_user_id, p_resource_id, p_start_time, p_end_time, 'confirmed', p_purpose
    );

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$;


--- otkazivanje rezervacije
CREATE OR REPLACE PROCEDURE prc_cancel_reservation (
    p_reservation_id INT
) 
LANGUAGE plpgsql AS $$
DECLARE
    v_current_status RESERVATIONS.status%TYPE;
BEGIN

    SELECT status INTO v_current_status
    FROM RESERVATIONS
    WHERE reservation_id = p_reservation_id
    FOR UPDATE;

    IF v_current_status IS NULL THEN
        RAISE EXCEPTION 'Greška: Rezervacija s ID-jem % ne postoji.', p_reservation_id USING ERRCODE = 'P0005';
    END IF;

    IF v_current_status = 'cancelled' THEN
        RAISE EXCEPTION 'Rezervacija je već otkazana.' USING ERRCODE = 'P0004';
    END IF;


    UPDATE RESERVATIONS
    SET status = 'cancelled'
    WHERE reservation_id = p_reservation_id;

    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;
$$;