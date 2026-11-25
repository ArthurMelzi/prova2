CREATE TABLE jogadores (
	id SERIAL PRIMARY KEY,
	nickname TEXT UNIQUE NOT NULL,
	senha TEXT NOT NULL,
	email TEXT UNIQUE NOT NULL,
    status TEXT DEFAULT 'Ativo' CHECK (status IN ('Ativo', 'Inativo'))
);

CREATE TABLE partidas (
    id SERIAL PRIMARY KEY,
	jogador_id INT REFERENCES jogadores(id),
	nome TEXT NOT NULL,
	categoria TEXT NOT NULL,
	data_partida DATE NOT NULL,
    status TEXT DEFAULT 'Não iniciado' CHECK (status IN ('Não iniciado', 'Cancelado', 'Iniciado', 'Finalizado'))
);

CREATE VIEW vw_painel_principal AS
SELECT
	jg.nickname AS jogador,
	ptd.nome AS titulo_partida,
	ptd.categoria AS categoria,
	ptd.data_partida AS data_partida,
	ptd.status AS status
FROM partidas ptd
JOIN jogadores jg ON jg.id = ptd.jogador_id

CREATE  FUNCTION fn_buscar_jogadores(p_nickname TEXT, p_email TEXT)
RETURNS TABLE (
	id INT,
	nickname TEXT,
	email TEXT,
	status TEXT
)
LANGUAGE plpgsql
AS $$ 
BEGIN
	RETURN QUERY
	SELECT
		jg.id,
		jg.nickname,
		jg.email,
		jg.status
	FROM jogadores jg
	WHERE jg.nickname = p_nickname OR jg.email = p_email;
END;
$$;

CREATE FUNCTION fn_validar_partida()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
	IF NEW.status = 'Inativo' THEN
	RAISE EXCEPTION 'O status do jogador NÃO pode ser inativo!';
	END IF;
	RETURN NEW;
END;
$$;

CREATE TRIGGER trg_validar_partida
BEFORE INSERT ON partidas
FOR EACH ROW
EXECUTE FUNCTION fn_validar_partida();

CREATE TABLE historico_partidas (
	id SERIAL PRIMARY KEY,
	jogador_id INT,
	nome TEXT NOT NULL,
	categoria TEXT NOT NULL,
	data_partida DATE NOT NULL,
    status TEXT DEFAULT 'Cancelado'
);

CREATE FUNCTION fn_insert_historico()
RETURNS TRIGGER
AS $$
BEGIN
    INSERT INTO historico_partidas(id, jogador_id, nome, categoria, data_partida, status)
    VALUES (NEW.id, NEW.jogador_id, NEW.nome, NEW.categoria, NEW.data_partida, NEW.status);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

INSERT INTO jogadores (nickname, senha, email, status) VALUES
('LuanGabriel', 'senha123', 'LuanGabriel@email.com', 'Ativo'),
('ArturHipólito', 'abc45678', 'ArturHipólito@email.com', 'Ativo'),
('ArthurMelzi', 'qwerty99', 'ArthurMelzi@email.com', 'Inativo'),
('GabrielLima', 'qweyyqw123', 'GabrielLima@email.com', 'Ativo');

INSERT INTO partidas (jogador_id, nome, categoria, data_partida, status) VALUES
(5, 'Duelo Noturno', 'FPS', '2026-11-25', 'Iniciado'),
(6, 'Torneio das Estrelas', 'MOBA', '2026-12-05', 'Não iniciado'),
(7, 'Amistoso de Fim de Semana', 'Esportes', '2026-11-15', 'Cancelado'),
(8, 'Desafio Ranked', 'Battle Royale', '2026-11-28', 'Não iniciado');
