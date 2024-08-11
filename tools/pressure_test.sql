DO $$
DECLARE
    reason TEXT := 'test';
    method PAYBY := 'credit card'::payby;
    m_from INT := 1;
    m_to INT := FLOOR(random() * 1000 + 1)::int;
    amount NUMERIC := 1;
BEGIN
    CALL transfer_funds(m_from, m_to, amount, reason, method);
END $$;
