CREATE INDEX idx_res_resource ON RESERVATIONS(resource_id);

CREATE INDEX idx_res_user ON RESERVATIONS(user_id);

CREATE INDEX idx_res_status_time ON RESERVATIONS(status, start_time, end_time); -- provjera preklapanja termina