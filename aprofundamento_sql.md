# ATIVIDADE DE APROFUNDAMENTO EM SCRIPTS SQL

## Banco de Dados: Sakila (MySQL)

---

## 1. Tipos de JOIN

**Conceito:**

- **INNER JOIN**: Retorna apenas registros com correspondência em ambas as tabelas
- **LEFT JOIN**: Retorna todos os registros da tabela esquerda + correspondentes da direita
- **RIGHT JOIN**: Retorna todos os registros da tabela direita + correspondentes da esquerda

### Desafio 1: INNER JOIN - Listar filmes com suas categorias

```sql
SELECT f.title, c.name AS categoria
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
ORDER BY f.title;
```

### Desafio 2: LEFT JOIN - Encontrar atores que nunca atuaram em filmes

```sql
SELECT a.first_name, a.last_name, fa.film_id
FROM actor a
LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id
WHERE fa.film_id IS NULL;
```

---

## 2. Múltiplos JOINs

**Conceito:** Conectar três ou mais tabelas em uma consulta, onde o resultado é construído progressivamente, unindo duas tabelas e depois o resultado com a terceira, e assim sucessivamente.

### Desafio 1: Relatório completo de aluguéis

```sql
SELECT c.first_name, c.last_name, f.title, cat.name AS categoria,
       r.rental_date, s.first_name AS staff_name
FROM rental r
INNER JOIN customer c ON r.customer_id = c.customer_id
INNER JOIN inventory i ON r.inventory_id = i.inventory_id
INNER JOIN film f ON i.film_id = f.film_id
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category cat ON fc.category_id = cat.category_id
INNER JOIN staff s ON r.staff_id = s.staff_id
LIMIT 10;
```

### Desafio 2: Atores, filmes e lojas onde estão disponíveis

```sql
SELECT a.first_name, a.last_name, f.title, st.store_id, ad.address
FROM actor a
INNER JOIN film_actor fa ON a.actor_id = fa.actor_id
INNER JOIN film f ON fa.film_id = f.film_id
INNER JOIN inventory i ON f.film_id = i.film_id
INNER JOIN store st ON i.store_id = st.store_id
INNER JOIN address ad ON st.address_id = ad.address_id
LIMIT 15;
```

---

## 3. Funções na Cláusula SELECT

**Conceito:** Usar funções para formatar, calcular e transformar dados diretamente no SELECT.

- **Texto**: CONCAT(), UPPER(), LOWER(), SUBSTRING(), LENGTH()
- **Numéricas**: ROUND(), CEIL(), FLOOR()
- **Nulos**: COALESCE(), IFNULL()

### Desafio 1: Formatação de nomes e informações de clientes

```sql
SELECT
    CONCAT(UPPER(first_name), ' ', UPPER(last_name)) AS nome_completo,
    CONCAT('Email: ', IFNULL(email, 'Não informado')) AS contato,
    LENGTH(CONCAT(first_name, last_name)) AS tamanho_nome
FROM customer
LIMIT 10;
```

### Desafio 2: Tratamento de valores nulos e arredondamento

```sql
SELECT
    title,
    ROUND(rental_rate, 0) AS preco_arredondado,
    COALESCE(special_features, 'Sem recursos especiais') AS recursos,
    CEIL(length/60.0) AS duracao_horas
FROM film
LIMIT 10;
```

---

## 4. Funções de Data e Hora

**Conceito:** Manipular e extrair informações de colunas de data/hora usando NOW(), CURDATE(), DATE_FORMAT(), DATEDIFF(), YEAR(), etc.

### Desafio 1: Calcular dias de aluguel

```sql
SELECT
    rental_id,
    rental_date,
    return_date,
    DATEDIFF(return_date, rental_date) AS dias_aluguel,
    DATE_FORMAT(rental_date, '%d/%m/%Y') AS data_formatada
FROM rental
WHERE return_date IS NOT NULL
LIMIT 15;
```

### Desafio 2: Análise temporal de aluguéis

```sql
SELECT
    YEAR(rental_date) AS ano,
    MONTH(rental_date) AS mes,
    COUNT(*) AS total_alugueis,
    DATE_ADD(rental_date, INTERVAL 7 DAY) AS vencimento_estimado
FROM rental
GROUP BY YEAR(rental_date), MONTH(rental_date)
ORDER BY ano, mes;
```

---

## 5. Subconsultas (Subqueries)

**Conceito:** Consultas dentro de outras consultas, podendo ser escalares (1 valor), múltiplas linhas (com IN, ANY, ALL) ou correlacionadas.

### Desafio 1: Subconsulta simples - Filmes da categoria 'Action'

```sql
SELECT title, rental_rate
FROM film
WHERE film_id IN (
    SELECT fc.film_id
    FROM film_category fc
    INNER JOIN category c ON fc.category_id = c.category_id
    WHERE c.name = 'Action'
);
```

### Desafio 2: Subconsulta correlacionada - Clientes acima da média de aluguéis

```sql
SELECT c.first_name, c.last_name,
       (SELECT COUNT(*) FROM rental r WHERE r.customer_id = c.customer_id) AS total_alugueis
FROM customer c
WHERE (SELECT COUNT(*) FROM rental r WHERE r.customer_id = c.customer_id) >
      (SELECT AVG(rental_count)
       FROM (SELECT COUNT(*) as rental_count FROM rental GROUP BY customer_id) as avg_rentals);
```

---

## 6. Subconsultas em Comandos DML

**Conceito:** Usar resultado de SELECT como fonte de dados ou critério para INSERT, UPDATE e DELETE.

### Desafio 1: UPDATE com subconsulta - Atualizar categoria especial

```sql
UPDATE film
SET special_features = 'Behind the Scenes,Deleted Scenes'
WHERE film_id IN (
    SELECT fc.film_id
    FROM film_category fc
    INNER JOIN category c ON fc.category_id = c.category_id
    WHERE c.name = 'Documentary'
);
```

### Desafio 2: DELETE com subconsulta - Remover aluguéis antigos

```sql
DELETE FROM rental
WHERE rental_id IN (
    SELECT rental_id
    FROM (
        SELECT rental_id
        FROM rental
        WHERE rental_date < '2005-06-01'
    ) AS old_rentals
);
```

---

## 7. WITH AS (CTE) e DISTINCT

**Conceito:**

- **DISTINCT**: Elimina duplicatas
- **CTE (WITH)**: Cria consulta nomeada temporária para simplificar scripts complexos

### Desafio 1: DISTINCT para contagem única

```sql
SELECT COUNT(DISTINCT customer_id) AS clientes_unicos,
       COUNT(DISTINCT film_id) AS filmes_alugados
FROM rental r
INNER JOIN inventory i ON r.inventory_id = i.inventory_id;
```

### Desafio 2: CTE para análise de clientes ativos

```sql
WITH clientes_ativos AS (
    SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) as total_alugueis
    FROM customer c
    INNER JOIN rental r ON c.customer_id = r.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name
    HAVING COUNT(r.rental_id) > 25
)
SELECT ca.first_name, ca.last_name, ca.total_alugueis,
       CASE
           WHEN ca.total_alugueis > 40 THEN 'VIP'
           WHEN ca.total_alugueis > 30 THEN 'Premium'
           ELSE 'Regular'
       END AS categoria_cliente
FROM clientes_ativos ca
ORDER BY ca.total_alugueis DESC;
```

---

## 8. Funções de Janela (Window Functions)

**Conceito:** Funções que calculam sobre conjunto de linhas relacionadas à linha atual usando OVER().

- **ROW_NUMBER()**: Número sequencial único
- **RANK()**: Ranking com saltos em empates
- **DENSE_RANK()**: Ranking sem saltos

### Desafio 1: Ranking de filmes por taxa de aluguel

```sql
SELECT title, rental_rate,
       ROW_NUMBER() OVER (ORDER BY rental_rate DESC) AS numero_sequencial,
       RANK() OVER (ORDER BY rental_rate DESC) AS ranking_com_salto,
       DENSE_RANK() OVER (ORDER BY rental_rate DESC) AS ranking_sem_salto
FROM film
ORDER BY rental_rate DESC
LIMIT 15;
```

### Desafio 2: Top 3 clientes por loja

```sql
SELECT customer_id, first_name, last_name, store_id, total_alugueis, ranking
FROM (
    SELECT c.customer_id, c.first_name, c.last_name, c.store_id,
           COUNT(r.rental_id) as total_alugueis,
           RANK() OVER (PARTITION BY c.store_id ORDER BY COUNT(r.rental_id) DESC) as ranking
    FROM customer c
    INNER JOIN rental r ON c.customer_id = r.customer_id
    GROUP BY c.customer_id, c.first_name, c.last_name, c.store_id
) ranked_customers
WHERE ranking <= 3;
```

---

## 9. Lógica Condicional com CASE

**Conceito:** Estrutura CASE WHEN ... THEN ... ELSE ... END para aplicar lógica IF/THEN/ELSE em consultas.

### Desafio 1: Classificar filmes por duração

```sql
SELECT title, length,
       CASE
           WHEN length <= 90 THEN 'Curta'
           WHEN length <= 120 THEN 'Média'
           WHEN length <= 150 THEN 'Longa'
           ELSE 'Muito Longa'
       END AS categoria_duracao
FROM film
ORDER BY length;
```

### Desafio 2: Categorizar clientes por atividade

```sql
SELECT c.first_name, c.last_name, COUNT(r.rental_id) as total_alugueis,
       CASE
           WHEN COUNT(r.rental_id) = 0 THEN 'Inativo'
           WHEN COUNT(r.rental_id) <= 10 THEN 'Baixa Atividade'
           WHEN COUNT(r.rental_id) <= 25 THEN 'Atividade Média'
           WHEN COUNT(r.rental_id) <= 35 THEN 'Alta Atividade'
           ELSE 'Super Ativo'
       END AS categoria_atividade
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_alugueis DESC;
```

---

## 10. Combinando Resultados com UNION

**Conceito:** UNION combina resultados de duas ou mais consultas, removendo duplicatas. UNION ALL não remove duplicatas (mais rápido).

### Desafio 1: Lista unificada de nomes (atores e clientes)

```sql
SELECT 'Ator' as tipo, first_name, last_name
FROM actor
UNION
SELECT 'Cliente' as tipo, first_name, last_name
FROM customer
ORDER BY last_name, first_name;
```

### Desafio 2: Relatório de pessoas por loja

```sql
SELECT 'Staff' as categoria, s.first_name, s.last_name, s.store_id
FROM staff s
UNION ALL
SELECT 'Cliente' as categoria, c.first_name, c.last_name, c.store_id
FROM customer c
ORDER BY store_id, categoria;
```

---

## 11. Visões (Views)

**Conceito:** Views são "tabelas virtuais" baseadas em consultas SELECT, oferecendo simplificação, reutilização e segurança.

### Desafio 1: Criar view de filmes com informações completas

```sql
-- Criar a VIEW
CREATE VIEW filme_detalhado AS
SELECT f.title, f.description, f.release_year, f.rental_rate,
       c.name AS categoria, l.name AS idioma
FROM film f
INNER JOIN film_category fc ON f.film_id = fc.film_id
INNER JOIN category c ON fc.category_id = c.category_id
INNER JOIN language l ON f.language_id = l.language_id;

-- Usar a VIEW
SELECT * FROM filme_detalhado
WHERE categoria = 'Action'
ORDER BY rental_rate DESC
LIMIT 10;
```

### Desafio 2: View para análise de clientes

```sql
-- Criar VIEW de resumo de clientes
CREATE VIEW resumo_cliente AS
SELECT c.customer_id, c.first_name, c.last_name, c.email,
       COUNT(r.rental_id) as total_alugueis,
       SUM(p.amount) as total_pago
FROM customer c
LEFT JOIN rental r ON c.customer_id = r.customer_id
LEFT JOIN payment p ON r.rental_id = p.rental_id
GROUP BY c.customer_id, c.first_name, c.last_name, c.email;

-- Consultar clientes mais valiosos
SELECT * FROM resumo_cliente
WHERE total_pago > 100
ORDER BY total_pago DESC;
```

---

## 12. Filtragem com WHERE vs. HAVING

**Conceito:**

- **WHERE**: Filtra linhas individuais antes do agrupamento
- **HAVING**: Filtra grupos após a agregação

### Desafio 1: Clientes que alugaram mais de 30 filmes

```sql
SELECT c.customer_id, c.first_name, c.last_name, COUNT(r.rental_id) as total_alugueis
FROM customer c
INNER JOIN rental r ON c.customer_id = r.customer_id
WHERE c.active = 1  -- WHERE filtra antes do GROUP BY
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING COUNT(r.rental_id) > 30  -- HAVING filtra após agregação
ORDER BY total_alugueis DESC;
```

### Desafio 2: Categorias com mais de 50 filmes

```sql
SELECT c.name AS categoria, COUNT(fc.film_id) as total_filmes
FROM category c
INNER JOIN film_category fc ON c.category_id = fc.category_id
INNER JOIN film f ON fc.film_id = f.film_id
WHERE f.rental_rate > 0.99  -- Filtro antes do agrupamento
GROUP BY c.category_id, c.name
HAVING COUNT(fc.film_id) > 50  -- Filtro após agregação
ORDER BY total_filmes DESC;
```

---

## 13. Controle de Transações

**Conceito:** Transação é um conjunto de operações SQL executadas como bloco único. Usa START TRANSACTION, COMMIT (salvar) e ROLLBACK (desfazer).

### Desafio 1: Registrar novo aluguel com transação

```sql
START TRANSACTION;

-- Inserir novo aluguel
INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id)
VALUES (NOW(), 1, 1, 1);

-- Atualizar estoque (marcar como alugado)
UPDATE inventory
SET last_update = NOW()
WHERE inventory_id = 1;

-- Se tudo correu bem, confirmar
COMMIT;

-- Em caso de erro, usar: ROLLBACK;
```

### Desafio 2: Transferir cliente entre lojas

```sql
START TRANSACTION;

-- Verificar se cliente existe
SELECT customer_id FROM customer WHERE customer_id = 1;

-- Atualizar loja do cliente
UPDATE customer
SET store_id = 2, last_update = NOW()
WHERE customer_id = 1;

-- Registrar na auditoria (tabela hipotética)
-- INSERT INTO customer_audit (customer_id, action, date) VALUES (1, 'STORE_TRANSFER', NOW());

COMMIT;
```

---

## 14. Gatilhos (Triggers)

**Conceito:** Trigger é um procedimento executado automaticamente em resposta a eventos INSERT, UPDATE ou DELETE em uma tabela.

### Desafio 1: Trigger de auditoria para tabela film

```sql
-- Criar tabela de log
CREATE TABLE film_audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    film_id INT,
    action_type VARCHAR(10),
    old_title VARCHAR(255),
    new_title VARCHAR(255),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Criar trigger para UPDATE
DELIMITER //
CREATE TRIGGER film_update_audit
AFTER UPDATE ON film
FOR EACH ROW
BEGIN
    INSERT INTO film_audit_log (film_id, action_type, old_title, new_title)
    VALUES (NEW.film_id, 'UPDATE', OLD.title, NEW.title);
END//
DELIMITER ;

-- Teste do trigger
UPDATE film SET title = 'NEW TITLE TEST' WHERE film_id = 1;
SELECT * FROM film_audit_log;
```

### Desafio 2: Trigger para controle de estoque

```sql
-- Trigger para atualizar data quando item é alugado
DELIMITER //
CREATE TRIGGER inventory_rental_update
AFTER INSERT ON rental
FOR EACH ROW
BEGIN
    UPDATE inventory
    SET last_update = NOW()
    WHERE inventory_id = NEW.inventory_id;
END//
DELIMITER ;
```

---

## 15. Índices e Otimização

**Conceito:** Índice é uma estrutura que acelera buscas em tabelas grandes, como um índice remissivo de livro. Criado com CREATE INDEX.

### Desafio 1: Identificar consulta lenta e criar índice

```sql
-- Consulta potencialmente lenta (busca por email)
EXPLAIN SELECT * FROM customer WHERE email = 'mary.smith@sakilacustomer.org';

-- Criar índice para otimizar
CREATE INDEX idx_customer_email ON customer(email);

-- Testar novamente
EXPLAIN SELECT * FROM customer WHERE email = 'mary.smith@sakilacustomer.org';
```

### Desafio 2: Índice composto para consultas complexas

```sql
-- Consulta que pode se beneficiar de índice composto
EXPLAIN SELECT * FROM rental
WHERE customer_id = 1 AND rental_date >= '2005-07-01';

-- Criar índice composto
CREATE INDEX idx_rental_customer_date ON rental(customer_id, rental_date);

-- Verificar melhoria
EXPLAIN SELECT * FROM rental
WHERE customer_id = 1 AND rental_date >= '2005-07-01';

-- Mostrar todos os índices da tabela
SHOW INDEX FROM rental;
```
