CREATE TABLE IF NOT EXISTS clientes (
    id SERIAL,
    nome VARCHAR(100) NOT NULL,
    limite INT NOT NULL,
    saldo_atual INT NOT NULL DEFAULT 0,
    PRIMARY KEY (id)
);

CREATE OR REPLACE FUNCTION limitar_clientes()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT COUNT(*) FROM clientes) >= 5 THEN
        RAISE EXCEPTION 'Limite máximo de clientes (5) atingido';
    ELSE
        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_cliente
BEFORE INSERT ON clientes
FOR EACH ROW
EXECUTE FUNCTION limitar_clientes();

CREATE TABLE IF NOT EXISTS transacoes (
    id SERIAL,
    cliente_id INT NOT NULL,
    valor INT NOT NULL,
    tipo BIT NOT NULL,
    descricao VARCHAR(10) NOT NULL 
        CHECK (LENGTH(descricao) >= 1 AND LENGTH(descricao) <= 10),
    PRIMARY KEY (id),
    CONSTRAINT fk_cliente_transacao FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE OR REPLACE FUNCTION validar_transacao()
RETURNS TRIGGER AS $$
DECLARE
    saldo_atual_cliente INT;
    limite_cliente INT;
BEGIN
    SELECT
        saldo_atual INTO saldo_atual_cliente
    FROM clientes
    WHERE id = NEW.cliente_id;

    SELECT
        limite INTO limite_cliente
    FROM clientes
    WHERE id = NEW.cliente_id;

    IF 
        NEW.tipo = B'0' 
            AND 
        (saldo_atual_cliente - NEW.valor) < (limite_cliente * -1) 
    THEN
        RAISE EXCEPTION 'Saldo inferior ao limite';
    END IF;

    RETURN NEW;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION atualizar_saldo()
RETURNS TRIGGER AS $$
DECLARE
    total_creditos INT;
    total_debitos INT;
BEGIN
    SELECT
        COALESCE(SUM(valor), 0) INTO total_creditos
    FROM transacoes
    WHERE tipo = B'1'
        AND cliente_id = NEW.cliente_id;

    SELECT 
        COALESCE(SUM(valor), 0) INTO total_debitos
    FROM transacoes
    WHERE tipo = B'0'
         AND cliente_id = NEW.cliente_id;

    UPDATE clientes
    SET saldo_atual = total_creditos - total_debitos
    WHERE id = NEW.cliente_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_transacao
BEFORE INSERT ON transacoes
FOR EACH ROW
EXECUTE FUNCTION validar_transacao();

CREATE TRIGGER after_insert_transacao
AFTER INSERT ON transacoes
FOR EACH ROW
EXECUTE FUNCTION atualizar_saldo();

DO $$
BEGIN
  INSERT INTO clientes (nome, limite)
  VALUES
    ('o barato sai caro', 1000 * 100),
    ('zan corp ltda', 800 * 100),
    ('les cruders', 10000 * 100),
    ('padaria joia de cocaia', 100000 * 100),
    ('kid mais', 5000 * 100);
END; $$