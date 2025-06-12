# Aprofundamento em Script SQL

**Trabalho Ronan - Leonardo Antoniassi**

---

## Item 1 – Tipos de JOIN em SQL

### 🔹 INNER JOIN

**O que faz:**  
Retorna somente os registros com correspondência em ambas as tabelas.

**Pense:**  
“Quero apenas os dados que existem nos dois lados.”

**Exemplo:**  
Alunos que têm matrículas. Se não houver correspondência, são excluídos.

---

### 🔹 LEFT JOIN

**O que faz:**  
Retorna todos os registros da tabela da esquerda e os correspondentes da direita (ou NULL se não houver).

**Pense:**  
“Quero tudo da esquerda e o que tiver da direita.”

**Exemplo:**  
Todos os alunos, com ou sem matrícula.

---

### 🔹 RIGHT JOIN

**O que faz:**  
O oposto do LEFT JOIN. Mostra todos da direita e os correspondentes da esquerda.

**Pense:**  
“Quero tudo da direita e o que tiver da esquerda.”

**Exemplo:**  
Todas as matrículas, com ou sem aluno.

---

### 🔹 FULL JOIN

**O que faz:**  
Retorna todos os registros de ambas as tabelas, com NULL onde não houver correspondência.

**Pense:**  
“Quero tudo de ambos os lados, mesmo que não combinem.”

---

### 💡 Desafio 1: INNER JOIN – Clientes com Compras Ativas

```sql
SELECT
    c.first_name,
    c.last_name,
    r.rental_id
FROM
    customer AS c
INNER JOIN
    rental AS r ON c.customer_id = r.customer_id;
```

---

### 💡 Desafio 2: LEFT JOIN – Produtos Sem Vendas no Último Mês

```sql
USE sakila;

SELECT
    f.title AS film_title,
    MAX(r.rental_date) AS ultima_locacao_em_maio_2005
FROM
    film AS f
LEFT JOIN
    inventory AS i ON f.film_id = i.film_id
LEFT JOIN
    rental AS r ON i.inventory_id = r.inventory_id
    AND r.rental_date >= '2005-05-01' AND r.rental_date < '2005-06-01'
GROUP BY
    f.title
ORDER BY
    f.title;
```

---

## Item 2 – Múltiplos JOINs

**Definição:**  
Permite unir mais de duas tabelas para construir consultas mais ricas.

---

### 💡 Desafio 1: Desempenho de Atores por Categoria e Localização

```sql
SELECT
    a.first_name,
    a.last_name,
    c.name AS category_name,
    ci.city AS store_city,
    COUNT(DISTINCT r.rental_id) AS total_rentals,
    SUM(p.amount) AS total_revenue
FROM
    actor AS a
INNER JOIN film_actor AS fa ON a.actor_id = fa.actor_id
INNER JOIN film AS f ON fa.film_id = f.film_id
INNER JOIN film_category AS fc ON f.film_id = fc.film_id
INNER JOIN category AS c ON fc.category_id = c.category_id
INNER JOIN inventory AS i ON f.film_id = i.film_id
INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
INNER JOIN payment AS p ON r.rental_id = p.rental_id
INNER JOIN store AS s ON i.store_id = s.store_id
INNER JOIN address AS ad ON s.address_id = ad.address_id
INNER JOIN city AS ci ON ad.city_id = ci.city_id
GROUP BY
    a.first_name, a.last_name, c.name, ci.city
ORDER BY
    a.first_name, a.last_name, c.name, ci.city;
```

---

### 💡 Desafio 2: Perfil de Clientes VIP por Idioma e País

```sql
SELECT
    c.first_name,
    c.last_name,
    COUNT(DISTINCT p.payment_id) AS total_payments,
    l.name AS preferred_language,
    cy.country AS customer_country,
    COUNT(r.rental_id) AS rentals_in_language_from_country
FROM
    customer AS c
INNER JOIN payment AS p ON c.customer_id = p.customer_id
LEFT JOIN rental AS r ON c.customer_id = r.customer_id
LEFT JOIN inventory AS i ON r.inventory_id = i.inventory_id
LEFT JOIN film AS f ON i.film_id = f.film_id
LEFT JOIN language AS l ON f.language_id = l.language_id
INNER JOIN address AS ad ON c.address_id = ad.address_id
INNER JOIN city AS ci ON ad.city_id = ci.city_id
INNER JOIN country AS cy ON ci.country_id = cy.country_id
GROUP BY
    c.customer_id, c.first_name, c.last_name, l.name, cy.country
HAVING
    COUNT(DISTINCT p.payment_id) >= 30
ORDER BY
    total_payments DESC, c.first_name, c.last_name, rentals_in_language_from_country DESC;
```

---

## Item 3 – Funções na Cláusula SELECT

### ✨ Funções de Texto (Strings)

- **CONCAT** – Junta strings
- **CONCAT_WS** – Junta strings com separador
- **UPPER / LOWER** – Caixa alta / baixa
- **SUBSTRING** – Parte de uma string
- **LENGTH** – Tamanho
- **REPLACE** – Substitui conteúdo

---

### ✨ Funções Numéricas

- **ROUND** – Arredondamento
- **CEIL / FLOOR** – Arredonda para cima / baixo

---

### ✨ Funções para Nulos

- **COALESCE** – Primeiro valor não nulo
- **IFNULL** – Retorna valor alternativo se for NULL

---

### 💡 Desafio 1: Relatório de Aluguéis Formatado

```sql
SELECT
    UPPER(CONCAT_WS(', ', c.last_name, c.first_name)) AS formatted_customer_name,
    CASE
        WHEN LENGTH(f.title) > 20 THEN CONCAT(SUBSTRING(f.title, 1, 17), '...')
        ELSE f.title
    END AS summarized_film_title,
    REPLACE(f.description, 'a', '@') AS modified_description,
    LENGTH(f.title) AS title_length
FROM
    rental AS r
INNER JOIN customer AS c ON r.customer_id = c.customer_id
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN film AS f ON i.film_id = f.film_id
LIMIT 10;
```

---

### 💡 Desafio 2: Relatório Financeiro com Tratamento

```sql
SELECT
    COALESCE(p.amount, 0.00) AS adjusted_amount,
    ROUND(f.rental_rate, 2) AS rounded_rental_rate,
    CEIL(p.amount) AS amount_rounded_up,
    FLOOR(p.amount) AS amount_rounded_down,
    COALESCE(p.payment_date, 'Data Desconhecida') AS payment_date_safe
FROM
    payment AS p
INNER JOIN rental AS r ON p.rental_id = r.rental_id
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN film AS f ON i.film_id = f.film_id
LIMIT 10;
```

---

## Item 4 – Funções de Data e Hora

### 📅 Funções Atuais

- **NOW()** – Data e hora atual
- **CURDATE()** – Somente data

---

### 📅 Extração de Partes

- **DAY / MONTH / YEAR** – Partes da data

---

### 📅 Formatação de Data

```sql
DATE_FORMAT(data, '%d/%m/%Y %H:%i')
-- Exemplo: '07/06/2025 14:56'
```

---

### 📅 Diferença e Cálculo com Datas

- **DATEDIFF()** – Diferença entre datas
- **DATE_ADD / DATE_SUB** – Adição/Subtração de tempo

---

### 💡 Desafio 1: Aluguéis e Prazos

```sql
SELECT
    DATE_FORMAT(r.rental_date, '%d/%m/%Y %H:%i') AS Aluguel_Em,
    DATE_FORMAT(DATE_ADD(r.rental_date, INTERVAL f.rental_duration DAY), '%d-%m-%Y') AS Devolucao_Prevista,
    DATEDIFF(r.return_date, r.rental_date) AS Dias_Alugado_Real,
    CASE
        WHEN r.return_date IS NOT NULL THEN 'Devolvido'
        ELSE 'Em Aberto'
    END AS Status_Aluguel
FROM
    rental AS r
INNER JOIN inventory AS i ON r.inventory_id = i.inventory_id
INNER JOIN film AS f ON i.film_id = f.film_id
ORDER BY r.rental_date DESC
LIMIT 10;
```

---

### 💡 Desafio 2: Pagamentos e Idade dos Clientes

```sql
SELECT
    DATE_FORMAT(p.payment_date, '%W, %d de %M de %Y') AS formatted_payment_date,
    YEAR(p.payment_date) AS payment_year,
    TIMESTAMPDIFF(YEAR, c.create_date, p.payment_date) AS customer_age_at_payment,
    DATE_FORMAT(c.create_date, '%m/%d/%Y') AS customer_creation_date_formatted
FROM
    payment AS p
INNER JOIN customer AS c ON p.customer_id = c.customer_id
ORDER BY p.payment_date DESC
LIMIT 10;
```

## Item 5 - Subconsultas

Subconsulta é uma SELECT dentro da outra.
Elas servem para quebrar problemas grandes em pedaços menores e mais fáceis de resolver.

### Subconsultas Escalares

O que retornam? Exatamente um único valor (uma única linha e uma única coluna).

Quando usar? Quando a consulta principal precisa de um valor específico para comparação, cálculo ou exibição.

```sql
-- Cenário: Encontrar todos os filmes com o mesmo custo de substituição do filme 'ACADEMY DINOSAUR'
SELECT
    title,
    replacement_cost
FROM
    film
WHERE
    replacement_cost = (SELECT replacement_cost FROM film WHERE title = 'ACADEMY DINOSAUR');
```

### Subconsultas de Múltiplas Linhas

O que retornam? Uma lista de valores (uma única coluna, mas com várias linhas).

Quando usar? Quando a consulta principal precisa comparar um valor com uma lista de possíveis valores. São usadas com operadores especiais:

IN: Verifica se um valor está dentro da lista retornada pela subconsulta. (Equivalente a = para um único valor, mas para múltiplos).

```sql
-- Cenário: Encontrar todos os filmes que foram alugados
SELECT
    title
FROM
    film
WHERE
    film_id IN (SELECT film_id FROM inventory); -- inventory armazena as cópias de filmes
```

NOT IN: Verifica se um valor não está na lista.
ANY (ou SOME): Verdadeiro se a comparação for verdadeira para qualquer valor da lista. (Ex: > ANY significa "maior que pelo menos um da lista").

```sql
-- Cenário: Encontrar filmes que NUNCA foram alugados (não estão no inventário)
SELECT
    title
FROM
    film
WHERE
    film_id NOT IN (SELECT film_id FROM inventory);
```

ALL: Verdadeiro se a comparação for verdadeira para todos os valores da lista. (Ex: > ALL significa "maior que todos da lista").
EXISTS: Verdadeiro se a subconsulta retornar qualquer linha (não importa o valor, apenas se há existência). Geralmente mais eficiente que IN em alguns cenários.

NOT EXISTS: Verdadeiro se a subconsulta não retornar nenhuma linha.

### Subconsultas Correlacionadas (ou Correlatas)

O que são? Subconsultas que dependem da consulta externa para sua execução.

Elas são executadas uma vez para cada linha processada pela consulta externa. Isso significa que a subconsulta usa um valor de uma coluna da consulta externa em sua cláusula WHERE.

Quando usar? Geralmente para comparações linha a linha, onde a subconsulta precisa de um contexto da linha atual da consulta principal.

```sql
-- Cenário: Encontrar clientes que alugaram mais de 30 filmes.
SELECT
    c.first_name,
    c.last_name
FROM
    customer AS c
WHERE
    (SELECT COUNT(*) FROM rental WHERE customer_id = c.customer_id) > 30;
```

Exemplo de Subconsulta na Cláusula FROM

```sql
SELECT
    cliente_id,
    AVG(valor_pagamento) AS MediaPagamentoPorCliente
FROM
    (SELECT customer_id AS cliente_id, amount AS valor_pagamento FROM payment) AS PagamentosDoCliente -- Subconsulta no FROM
GROUP BY
    cliente_id
HAVING
    SUM(valor_pagamento) > 100;
```

Exemplo de Subconsulta na Cláusula SELECT

```sql
SELECT
    f.title,
    (SELECT COUNT(*) FROM film_actor AS fa WHERE fa.film_id = f.film_id) AS NumeroDeAtores -- Subconsulta no SELECT
FROM
    film AS f
ORDER BY
    f.title;
```

#### Desafio 1: "Atores em Filmes de Comédia" (Subconsulta Simples com IN)

Cenário: O estúdio Sakila está planejando um novo filme de comédia e quer ver uma lista de todos os atores que já atuaram em qualquer filme do gênero 'Comedy'. Eles precisam dos nomes desses atores, sem duplicações.

```sql
SELECT DISTINCT
    a.first_name,
    a.last_name
FROM
    actor AS a
JOIN
    film_actor AS fa ON a.actor_id = fa.actor_id
WHERE
    fa.film_id IN (
        SELECT
            fc.film_id
        FROM
            film_category AS fc
        JOIN
            category AS c ON fc.category_id = c.category_id
        WHERE
            c.name = 'Comedy'
    );
```

#### Desafio 2: "Clientes com Aluguéis Acima da Média" (Subconsulta Correlacionada)

Cenário: O departamento de fidelidade da Sakila quer identificar os clientes mais ativos. Eles definiram como "cliente ativo" aquele que tem um valor total de pagamentos de aluguéis maior do que a média de pagamentos de aluguel por filme específico (ou seja, a média dos valores de aluguel de um mesmo filme).

```sql
SELECT
    c.first_name,
    c.last_name
FROM
    customer AS c
WHERE
    (SELECT SUM(p.amount) FROM payment AS p WHERE p.customer_id = c.customer_id)
    >
    (SELECT AVG(f.rental_rate)
     FROM rental AS r
     JOIN inventory AS i ON r.inventory_id = i.inventory_id
     JOIN film AS f ON i.film_id = f.film_id
     WHERE r.customer_id = c.customer_id
    );
```

## item 6 - Subconsultas em comandos DML

A ideia principal é que o resultado de uma subconsulta SELECT pode ser usado como uma fonte de dados ou como um critério de filtro para operações de manipulação de dados em massa. Isso permite que você realize operações complexas que seriam muito difíceis ou impossíveis de fazer com comandos DML simples.

```sql
INSERT INTO nome_da_tabela (coluna1, coluna2, ...)
SELECT coluna_origem1, coluna_origem2, ...
FROM outra_tabela
WHERE condição_da_subconsulta;
```

Exemplo (Sakila):
Imagine que queremos criar uma nova tabela temporária Atores_Populares e preenchê-la com atores que atuaram em mais de 30 filmes.

```sql
-- 1. Cria a tabela (se não existir, ou exclui e cria para testar)
-- DROP TABLE IF EXISTS Atores_Populares; -- Use com cautela!
CREATE TABLE Atores_Populares (
    ator_id INT PRIMARY KEY,
    nome_completo VARCHAR(100)
);

-- 2. Insere dados usando uma subconsulta
INSERT INTO Atores_Populares (ator_id, nome_completo)
SELECT
    a.actor_id,
    CONCAT_WS(' ', a.first_name, a.last_name)
FROM
    actor AS a
WHERE
    (SELECT COUNT(*) FROM film_actor WHERE actor_id = a.actor_id) > 30;
```

#### Subconsultas em UPDATE

Como funciona? O resultado de uma subconsulta pode ser usado:

Na cláusula SET para definir o novo valor de uma coluna.
Na cláusula WHERE para filtrar quais linhas devem ser atualizadas.

```sql
-- Usando subconsulta no SET
UPDATE nome_da_tabela
SET coluna_a_atualizar = (SELECT valor_calculado FROM outra_tabela WHERE condição)
WHERE condição_da_atualizacao;

-- Usando subconsulta no WHERE (mais comum para filtros complexos)
UPDATE nome_da_tabela
SET coluna_a_atualizar = novo_valor
WHERE id IN (SELECT id_para_atualizar FROM outra_tabela WHERE condição);
```

#### Subconsultas em DELETE

Como funciona? O resultado de uma subconsulta é usado na cláusula WHERE para especificar quais linhas devem ser excluídas.

Para que serve? Para remover dados em massa com base em condições complexas ou em dados de outras tabelas.

```sql
DELETE FROM nome_da_tabela
WHERE id IN (SELECT id_para_excluir FROM outra_tabela WHERE condição);
```

#### Desafio 1: "Atualizando Taxa de Aluguel de Filmes Infantis" (UPDATE com Subconsulta)

Cenário: O gerente da locadora Sakila notou que os filmes classificados como Children (Infantil) têm uma taxa de aluguel muito baixa em comparação com outros gêneros populares. Para aumentar a receita, ele decidiu aumentar em 0.99 o rental_rate de todos os filmes que pertencem à categoria 'Children'.

```sql
UPDATE film
SET
    rental_rate = rental_rate + 0.99
WHERE
    film_id IN (
        SELECT
            fc.film_id
        FROM
            film_category AS fc
        JOIN
            category AS c ON fc.category_id = c.category_id
        WHERE
            c.name = 'Children'
    );
```

#### Desafio 2: "Removendo Clientes Inativos Sem Aluguéis" (DELETE com Subconsulta)

Cenário: O banco de dados da Sakila está ficando grande e o setor de conformidade quer limpar dados de clientes que estão há muito tempo na base, mas nunca fizeram nenhum aluguel. Clientes que fizeram pelo menos um aluguel devem ser mantidos.

```sql
DELETE FROM customer
WHERE
    customer_id NOT IN (
        SELECT DISTINCT
            r.customer_id
        FROM
            rental AS r
    );
```

## item 7 - WITH AS (CTE) e DISTINCT

DISTINCT é como um filtro de 'só quero uma de cada'. Se o seu resultado tem linhas exatamente iguais, ele remove as repetidas e mostra só uma.

#### Distinct

#### Por que usar?

Simplificação de Consultas Complexas: Quebra consultas grandes e complexas em blocos lógicos menores e mais gerenciáveis.

Legibilidade: Melhora a compreensão do código, pois cada CTE pode resolver uma parte específica do problema.

Reutilização (dentro da mesma query): Uma CTE pode ser referenciada várias vezes dentro da mesma consulta principal.

Alternativa a Subconsultas Aninhadas: Às vezes, torna consultas mais legíveis do que subconsultas profundamente aninhadas no FROM ou WHERE.

```sql
SELECT DISTINCT coluna1, coluna2
FROM nome_da_tabela
WHERE condição;
```

#### With

As CTEs (com WITH) são como criar 'tabelas temporárias inteligentes' para organizar sua consulta. Em vez de fazer uma bagunça de JOINs e subconsultas tudo de uma vez, você cria blocos nomeados (CTE1, CTE2, etc.) que fazem uma parte do trabalho. Depois, na sua SELECT final, você usa esses blocos como se fossem tabelas comuns. Isso deixa o código muito mais fácil de ler e entender!

```sql
WITH NomeDaCTE1 AS (
    SELECT coluna1, coluna2
    FROM tabela_origem
    WHERE condição_da_cte1
),
NomeDaCTE2 AS ( -- Opcional: Pode referenciar CTE1
    SELECT a.coluna_a, b.coluna_b
    FROM NomeDaCTE1 AS a
    JOIN outra_tabela AS b ON a.chave = b.chave
    WHERE condição_da_cte2
)
-- Consulta Principal que usa as CTEs
SELECT final_coluna1, final_coluna2
FROM NomeDaCTE1
JOIN NomeDaCTE2 ON NomeDaCTE1.chave = NomeDaCTE2.chave
WHERE condição_final;
```

#### Desafio 1: "Quantos Filmes Únicos Foram Alugados?" (DISTINCT para Contagem Única)

Cenário: O setor de análise de dados da Sakila precisa de uma métrica simples: quantos filmes diferentes foram alugados, independentemente de quantas cópias de cada filme ou quantas vezes ele foi alugado. Eles querem a contagem dos títulos únicos de filmes que aparecem em pelo menos um registro de aluguel.

```sql
SELECT
    COUNT(DISTINCT f.film_id) AS total_filmes_unicos_alugados
FROM
    rental AS r
JOIN
    inventory AS i ON r.inventory_id = i.inventory_id
JOIN
    film AS f ON i.film_id = f.film_id;
```

#### desafio 2: "Relatório de Clientes e seus Gêneros Mais Alugados" (CTE para Clareza)

Cenário: O time de marketing quer entender melhor os clientes. Eles precisam de um relatório que mostre o nome completo de cada cliente e, para cada cliente, o gênero de filme que ele mais alugou. Se um cliente alugou a mesma quantidade de filmes de dois ou mais gêneros, qualquer um deles pode ser exibido. Clientes que não alugaram nada não precisam aparecer.

```sql
WITH ClienteAluguelGenero AS (
    -- CTE 1: Associa cada aluguel ao cliente e ao nome do gênero do filme
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        cat.name AS genre_name
    FROM
        customer AS c
    JOIN
        rental AS r ON c.customer_id = r.customer_id
    JOIN
        inventory AS i ON r.inventory_id = i.inventory_id
    JOIN
        film AS f ON i.film_id = f.film_id
    JOIN
        film_category AS fc ON f.film_id = fc.film_id
    JOIN
        category AS cat ON fc.category_id = cat.category_id
),
ContagemGeneroPorCliente AS (
    -- CTE 2: Conta quantos filmes de cada gênero o cliente alugou
    SELECT
        cag.customer_id,
        cag.first_name,
        cag.last_name,
        cag.genre_name,
        COUNT(cag.genre_name) AS quantidade_alugueis_genero
    FROM
        ClienteAluguelGenero AS cag
    GROUP BY
        cag.customer_id,
        cag.first_name,
        cag.last_name,
        cag.genre_name
),
GeneroMaisAlugadoRankeado AS (
    -- CTE 3: Ranqueia os gêneros para cada cliente com base na quantidade de aluguéis
    SELECT
        cgpc.customer_id,
        cgpc.first_name,
        cgpc.last_name,
        cgpc.genre_name,
        cgpc.quantidade_alugueis_genero,
        ROW_NUMBER() OVER (PARTITION BY cgpc.customer_id ORDER BY cgpc.quantidade_alugueis_genero DESC) AS rnk
    FROM
        ContagemGeneroPorCliente AS cgpc
)
-- Consulta Final: Seleciona o gênero com o rank 1 para cada cliente
SELECT
    gmarl.first_name,
    gmarl.last_name,
    gmarl.genre_name AS genero_mais_alugado
FROM
    GeneroMaisAlugadoRankeado AS gmarl
WHERE
    gmarl.rnk = 1
ORDER BY
    gmarl.last_name, gmarl.first_name;
```

## Item 8 - Funções de Janela para Ranking

As Funções de Janela (ou Window Functions) realizam um cálculo sobre um conjunto de linhas que estão "relacionadas" ou "dentro da mesma janela" da linha atual, sem realmente "agrupar" essas linhas e reduzir o número de resultados.

```sql
FUNCAO_DE_JANELA() OVER (
    PARTITION BY coluna_para_agrupar_logicamente, ...
    ORDER BY coluna_para_ordenar_dentro_do_grupo ASC/DESC, ...
) AS nome_da_coluna_de_resultado
```

#### ROW_NUMBER()

Atribui um número sequencial único a cada linha dentro da sua partição, com base na ordem definida pelo ORDER BY. Se houver empates na ordenação, o número é atribuído arbitrariamente (a ordem dos empates não é garantida).

```sql
SELECT
    film_id,
    title,
    rental_rate,
    ROW_NUMBER() OVER (ORDER BY rental_rate DESC) AS RankingGeralTaxa
FROM
    film;
```

#### RANK()

Atribui um ranking a cada linha dentro da sua partição. Se houver empates, todos os itens empatados recebem o mesmo ranking, e o próximo ranking pula o número de posições ocupadas pelos empates.

```sql
SELECT
    film_id,
    title,
    rental_rate,
    RANK() OVER (ORDER BY rental_rate DESC) AS RankingComSaltoTaxa
FROM
    film;
```

#### DENSE_RANK(

)

Atribui um ranking a cada linha dentro da sua partição. Se houver empates, todos os itens empatados recebem o mesmo ranking, mas o próximo ranking não pula posições.

```sql
SELECT
    film_id,
    title,
    rental_rate,
    DENSE_RANK() OVER (ORDER BY rental_rate DESC) AS RankingSemSaltoTaxa
FROM
    film;
```

#### Desafio 1: "Top 5 Filmes Mais Alugados por Categoria"

Cenário: O departamento de merchandising da Sakila quer criar uma vitrine especial para os filmes mais populares. Eles precisam de uma lista dos 5 filmes mais alugados em CADA GÊNERO/CATEGORIA.

```sql
WITH FilmesAlugadosPorCategoria AS (
    -- 1. Conta o total de aluguéis por filme e categoria
    SELECT
        cat.name AS categoria_nome,
        f.title AS titulo_filme,
        COUNT(r.rental_id) AS total_alugueis
    FROM
        category AS cat
    JOIN film_category AS fc ON cat.category_id = fc.category_id
    JOIN film AS f ON fc.film_id = f.film_id
    JOIN inventory AS i ON f.film_id = i.film_id
    JOIN rental AS r ON i.inventory_id = r.inventory_id
    GROUP BY
        cat.name,
        f.title
),
RankingDosFilmes AS (
    -- 2. Atribui um ranking a cada filme DENTRO de sua categoria
    SELECT
        categoria_nome,
        titulo_filme,
        total_alugueis,
        DENSE_RANK() OVER (PARTITION BY categoria_nome ORDER BY total_alugueis DESC) AS ranking_na_categoria
    FROM
        FilmesAlugadosPorCategoria
)
-- 3. Seleciona apenas os filmes que estão no Top 5 de cada categoria
SELECT
    categoria_nome,
    titulo_filme,
    total_alugueis,
    ranking_na_categoria
FROM
    RankingDosFilmes
WHERE
    ranking_na_categoria <= 5
ORDER BY
    categoria_nome,
    ranking_na_categoria;
```

#### Desafio 2: "Identificando o Cliente Mais Leal por Loja e Seus Top 3 Pagamentos"

Cenário: A gerência da Sakila quer reconhecer os clientes mais fiéis de cada uma de suas lojas. Eles precisam de um relatório que mostre o cliente que mais gastou em cada loja, e os detalhes dos seus três maiores pagamentos individuais.

```sql
WITH GastosPorClienteLoja AS (
    -- 1. Soma o gasto de cada cliente em cada loja
    SELECT
        st.store_id,
        c.customer_id,
        c.first_name,
        c.last_name,
        SUM(p.amount) AS total_gasto
    FROM
        customer AS c
    JOIN payment AS p ON c.customer_id = p.customer_id
    JOIN staff AS s ON p.staff_id = s.staff_id
    JOIN store AS st ON s.store_id = st.store_id
    GROUP BY
        st.store_id, c.customer_id, c.first_name, c.last_name
),
RankingClientesLeais AS (
    -- 2. Identifica o cliente que mais gastou em cada loja
    SELECT
        store_id,
        customer_id,
        first_name,
        last_name,
        total_gasto,
        RANK() OVER (PARTITION BY store_id ORDER BY total_gasto DESC) AS rank_leal
    FROM
        GastosPorClienteLoja
),
PagamentosRankeados AS (
    -- 3. Ranqueia os pagamentos individuais de cada cliente
    SELECT
        s.store_id,
        c.customer_id,
        p.amount AS valor_pagamento,
        p.payment_date AS data_pagamento,
        ROW_NUMBER() OVER (PARTITION BY c.customer_id ORDER BY p.amount DESC, p.payment_date DESC) AS rank_pag_ind
    FROM
        customer AS c
    JOIN payment AS p ON c.customer_id = p.customer_id
    JOIN staff AS st ON p.staff_id = st.staff_id
    JOIN store AS s ON st.store_id = s.store_id
)
-- 4. Combina tudo: Top cliente de cada loja E seus 3 maiores pagamentos
SELECT
    rcl.store_id,
    rcl.first_name,
    rcl.last_name,
    pr.valor_pagamento,
    pr.data_pagamento,
    pr.rank_pag_ind
FROM
    RankingClientesLeais AS rcl
JOIN
    PagamentosRankeados AS pr
    ON rcl.customer_id = pr.customer_id
    AND rcl.store_id = pr.store_id -- Importante para ligar o pagamento à loja certa
WHERE
    rcl.rank_leal = 1 -- Pega só o cliente mais leal da loja
    AND pr.rank_pag_ind <= 3 -- Pega os 3 maiores pagamentos DELE
ORDER BY
    rcl.store_id, rcl.first_name, pr.rank_pag_ind;
```

## item 9 - Lógica Condicional com CASE

O CASE WHEN é uma expressão condicional que permite aplicar lógica IF/THEN/ELSE (ou SE/ENTÃO/SENÃO) diretamente dentro de uma consulta SQL.
Ele avalia uma ou mais condições e retorna um valor diferente para cada condição que for verdadeira.
Se nenhuma condição for atendida, ele pode retornar um valor padrão.

#### Desafio 1: "Classificação de Filmes por Custo de Substituição"

Cenário: A equipe de catalogação da Sakila precisa de uma nova classificação para os filmes baseada em seu replacement_cost (custo de substituição). Isso os ajudará a priorizar a reposição de filmes mais caros.

```sql
SELECT
    title,
    replacement_cost, -- Opcional: para ver o custo original e verificar a classificação
    CASE
        WHEN replacement_cost <= 10.00 THEN 'Baixo Custo'
        WHEN replacement_cost BETWEEN 10.01 AND 20.00 THEN 'Custo Médio'
        WHEN replacement_cost > 20.00 THEN 'Alto Custo'
        ELSE 'Custo Indefinido' -- Caso haja valores NULL ou fora das faixas esperadas
    END AS NivelCustoSubstituicao
FROM
    film
ORDER BY
    replacement_cost; -- Ordenar ajuda a visualizar a classificação
```

#### Desafio 2: "Status de Atividade dos Clientes"

Cenário: O departamento de fidelidade da Sakila quer segmentar os clientes com base na sua atividade recente. Eles precisam de um relatório que mostre o status de cada cliente.

```sql
SELECT
    c.first_name,
    c.last_name,
    -- Opcional: para visualização da data do último aluguel e diferença de dias
    MAX(r.rental_date) AS last_rental_date,
    DATEDIFF(CURDATE(), MAX(r.rental_date)) AS days_since_last_rental,
    CASE
        WHEN MAX(r.rental_date) IS NULL THEN 'Inativo' -- Cliente nunca alugou
        WHEN DATEDIFF(CURDATE(), MAX(r.rental_date)) <= 30 THEN 'Ativo Recente'
        WHEN DATEDIFF(CURDATE(), MAX(r.rental_date)) BETWEEN 31 AND 90 THEN 'Ativo Moderado'
        WHEN DATEDIFF(CURDATE(), MAX(r.rental_date)) > 90 THEN 'Inativo'
        ELSE 'Status Desconhecido' -- Catch-all para qualquer caso não coberto
    END AS StatusAtividade
FROM
    customer AS c
LEFT JOIN
    rental AS r ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id, c.first_name, c.last_name -- Agrupar por todos os campos SELECT não agregados
ORDER BY
    StatusAtividade, last_rental_date DESC; -- Ordenar para melhor visualização
```

## Item 10 - Combinando Resultados com UNION

Eles servem pra combinar os resultados de duas ou mais consultas SELECT em um conjunto só.

A Diferença Crucial: UNION vs. UNION ALL
Ambos combinam, mas a grande diferença é como eles lidam com linhas repetidas:

1. UNION
   O que faz: Junta os resultados e, se houver linhas exatamente iguais (com os mesmos valores em todas as colunas), ele remove as duplicatas. Cada linha no resultado final é única.

2. UNION ALL
   O que faz: Junta os resultados e inclui todas as linhas, mesmo as que são duplicadas. Se uma linha aparece em ambas as consultas, ou várias vezes em uma delas, ela aparecerá tantas vezes quanto existir nas fontes.

A escolha entre UNION e UNION ALL é simples: precisa de uma lista única e limpa? Use UNION. Precisa de todos os resultados combinados, mesmo com repetições, e quer mais performance? Use UNION ALL.

#### Desafio: "Lista Consolidada de Pessoas no Ecossistema Sakila"

Cenário: O time de análise de dados da Sakila está fazendo um estudo sobre todas as "pessoas" que interagem com a locadora. Eles precisam de uma lista única e consolidada contendo os nomes completos de todos os clientes e todos os funcionários. Para essa lista, eles não querem nomes duplicados.

```sql
SELECT
    CONCAT_WS(' ', first_name, last_name) AS NomeCompleto
FROM
    customer

UNION

SELECT
    CONCAT_WS(' ', first_name, last_name) AS NomeCompleto
FROM
    staff
ORDER BY
    NomeCompleto;
```

## Item 11 - Visões(Views)

Uma Visão (ou View) é, em sua essência, uma "tabela virtual" baseada no resultado de uma consulta SELECT armazenada no banco de dados. Ela não armazena os dados fisicamente (como uma tabela comum), mas sim a definição da consulta.

```sql
CREATE VIEW nome_da_visao AS
SELECT coluna1, coluna2, ...
FROM tabela1
JOIN tabela2 ON condicao
WHERE condicao_de_filtro;
```

#### Desafio 1: "Atores em Filmes de Comédia" (Subconsulta Simples com IN)

Cenário: O estúdio Sakila está planejando um novo filme de comédia e quer ver uma lista de todos os atores que já atuaram em qualquer filme do gênero 'Comedy'. Eles precisam dos nomes desses atores, sem duplicações.

```sql
SELECT DISTINCT
    a.first_name,
    a.last_name
FROM
    actor AS a
JOIN
    film_actor AS fa ON a.actor_id = fa.actor_id
WHERE
    fa.film_id IN (
        SELECT
            fc.film_id
        FROM
            film_category AS fc
        JOIN
            category AS c ON fc.category_id = c.category_id
        WHERE
            c.name = 'Comedy'
    );
```

#### Desafio 2: "Clientes com Aluguéis Acima da Média" (Subconsulta Correlacionada)

Cenário: O departamento de fidelidade da Sakila quer identificar os clientes mais ativos. Eles definiram como "cliente ativo" aquele que tem um valor total de pagamentos de aluguéis maior do que a média dos valores de aluguel de cada filme que ele alugou.

```sql
SELECT
    c.first_name,
    c.last_name
FROM
    customer AS c
WHERE
    (SELECT SUM(p.amount) FROM payment AS p WHERE p.customer_id = c.customer_id)
    >
    (SELECT AVG(f.rental_rate)
     FROM rental AS r
     JOIN inventory AS i ON r.inventory_id = i.inventory_id
     JOIN film AS f ON i.film_id = f.film_id
     WHERE r.customer_id = c.customer_id
    );
```

## Item 12 - Filtragem com WHERE vs. HAVING

WHERE
O que faz: Filtra linhas individuais antes que qualquer agrupamento (GROUP BY) ou função de agregação (SUM, COUNT, AVG, MAX, MIN) seja aplicada.

Quando usar: Para filtrar dados baseando-se em condições sobre colunas originais da tabela (ou colunas que não são resultados de agregação).

HAVING
O que faz: Filtra grupos de linhas depois que o agrupamento (GROUP BY) e as funções de agregação foram aplicados.

Quando usar: Para filtrar dados baseando-se em condições sobre resultados de funções de agregação ou sobre as próprias colunas de agrupamento, mas só depois que os grupos foram formados.

Fluxo de Execução Simplificado (com GROUP BY):
FROM / JOINs: As tabelas são combinadas.

WHERE: As linhas individuais são filtradas.

GROUP BY: As linhas restantes são agrupadas.

Funções de Agregação: Cálculos como SUM, COUNT, AVG são aplicados a cada grupo.

HAVING: Os grupos (com seus resultados agregados) são filtrados.

SELECT: As colunas finais são selecionadas.

ORDER BY: Os resultados são ordenados.

LIMIT: O número de resultados é limitado.

#### Desafio: "Clientes Ativos com Média de Pagamento Elevada"

Cenário: O departamento de finanças e marketing da Sakila está procurando por clientes "VIPs". Eles definem um cliente VIP como aquele que fez pelo menos 10 pagamentos e cuja média de valor por pagamento é superior a $4.50.

```sql
SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(p.payment_id) AS TotalPagamentos,
    AVG(p.amount) AS MediaValorPagamento
FROM
    customer AS c
JOIN
    payment AS p ON c.customer_id = p.customer_id
GROUP BY
    c.customer_id, c.first_name, c.last_name
HAVING
    COUNT(p.payment_id) >= 10
    AND AVG(p.amount) > 4.50
ORDER BY
    MediaValorPagamento DESC, TotalPagamentos DESC;
```

## Item 13 - Controle de Transações (COMMIT e ROLLBACK)

Uma Transação é um conjunto de uma ou mais operações SQL (como INSERT, UPDATE, DELETE) que são tratadas como uma unidade lógica única e indivisível. Isso significa que:

Atomicidade (O Principal): Todas as operações dentro de uma transação devem ser completadas com sucesso (totalmente) ou nenhuma delas deve ser completada (totalmente desfeita).

#### Desafio: Registro de Aluguel como Transação no Sakila

Cenário de Negócio: "Processando um Novo Aluguel de Filme"
No Sakila, um novo aluguel envolve duas ações críticas para manter a integridade dos dados: registrar o aluguel na tabela rental e atualizar o status do item no inventory. Se uma dessas operações falhar, a base de dados pode ficar inconsistente.

```sql
--- CENÁRIO DE SUCESSO: Todas as operações serão bem-sucedidas ---
Descomente este bloco e execute para ver o COMMIT
START TRANSACTION;

SET @customer_id_aluguel = 1; -- Cliente existente
SET @inventory_id_aluguel = 2; -- ID de inventário existente (assumido como 'disponível')
SET @staff_id_aluguel = 1; -- Funcionário existente
SET @rental_date_aluguel = NOW();

-- 1. Inserir o novo registro de aluguel
INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id, last_update)
VALUES (@rental_date_aluguel, @inventory_id_aluguel, @customer_id_aluguel, @staff_id_aluguel, NOW());

-- Verifica se o INSERT foi bem-sucedido
SET @insert_ok = (SELECT ROW_COUNT());

-- 2. Atualizar o item no inventário
UPDATE inventory
SET last_update = @rental_date_aluguel -- Marca como movimentado
WHERE inventory_id = @inventory_id_aluguel;

-- Verifica se o UPDATE foi bem-sucedido
SET @update_ok = (SELECT ROW_COUNT());

IF @insert_ok > 0 AND @update_ok > 0 THEN
    SELECT 'Ambas as operações bem-sucedidas. Commitando transação.';
    COMMIT;
ELSE
    SELECT 'Falha em uma ou ambas as operações. Rollback da transação.';
    ROLLBACK;
END IF;

-- --- CENÁRIO DE FALHA: A atualização do inventário falhará para demonstrar o ROLLBACK ---
-- Descomente este bloco e execute para ver o ROLLBACK
START TRANSACTION;

SET @customer_id_aluguel = 1; -- Cliente existente
SET @inventory_id_aluguel = 3; -- ID de inventário existente
SET @staff_id_aluguel = 1; -- Funcionário existente
SET @rental_date_aluguel = NOW();

-- 1. Inserir o novo registro de aluguel (esta parte será bem-sucedida)
INSERT INTO rental (rental_date, inventory_id, customer_id, staff_id, last_update)
VALUES (@rental_date_aluguel, @inventory_id_aluguel, @customer_id_aluguel, @staff_id_aluguel, NOW());

-- Verifica se o INSERT foi bem-sucedido
SET @insert_ok = (SELECT ROW_COUNT());

-- 2. SIMULAR UMA FALHA NA ATUALIZAÇÃO DO INVENTÁRIO
-- Tentando atualizar um inventory_id que NÃO EXISTE, forçando 0 linhas afetadas
UPDATE inventory
SET last_update = @rental_date_aluguel
WHERE inventory_id = 999999; -- ID inexistente para simular falha

-- Verifica se o UPDATE foi bem-sucedido (neste caso, será 0)
SET @update_ok = (SELECT ROW_COUNT());

IF @insert_ok > 0 AND @update_ok > 0 THEN
    SELECT 'Ambas as operações bem-sucedidas. Commitando transação.';
    COMMIT;
ELSE
    SELECT 'Falha em uma ou ambas as operações. Rollback da transação.';
    ROLLBACK;
END IF;

```

## Item 14 - Gatilhos(Triggers)

Um Gatilho (Trigger) é um procedimento armazenado (um bloco de código SQL) que é executado automaticamente em resposta a um evento específico de modificação de dados (INSERT, UPDATE ou DELETE) em uma tabela específica.

Evento: O gatilho é associado a um tipo de operação DML (Data Manipulation Language):

INSERT: Dispara quando novas linhas são adicionadas.

UPDATE: Dispara quando linhas existentes são modificadas.

DELETE: Dispara quando linhas são removidas.

Momento (Timing): O gatilho pode ser executado:

BEFORE (Antes): O código do gatilho é executado antes da operação DML ser aplicada à tabela. Útil para validação, modificação dos dados que serão inseridos/atualizados.

AFTER (Depois): O código do gatilho é executado depois da operação DML ser aplicada à tabela. Útil para auditoria, replicação de dados.

Tabela: O gatilho é sempre associado a uma única tabela.

#### Desafio: Desafio: Gatilho para Auditoria de Atualizações de Filmes no Sakila

Cenário de Negócio: "Auditoria de Alterações em Filmes"
O gerente da Sakila está preocupado com a qualidade e consistência dos dados dos filmes no catálogo. Ele quer ter um registro detalhado de todas as vezes que qualquer informação de um filme é atualizada (ex: título, duração, taxa de aluguel, etc.). Esse registro deve incluir quem fez a alteração, quando e quais foram os valores antigos e novos de algumas colunas importantes.

```sql
CREATE TABLE film_audit_log (
    audit_id INT PRIMARY KEY AUTO_INCREMENT, -- Chave primária auto-incrementável para o log
    film_id SMALLINT NOT NULL,              -- ID do filme que foi atualizado
    old_title VARCHAR(255),                 -- Título do filme antes da atualização
    new_title VARCHAR(255),                 -- Título do filme depois da atualização
    old_rental_rate DECIMAL(4, 2),          -- Taxa de aluguel antes da atualização
    new_rental_rate DECIMAL(4, 2),          -- Taxa de aluguel depois da atualização
    change_timestamp DATETIME NOT NULL,     -- Data e hora exata da alteração
    changed_by_user VARCHAR(255) NOT NULL   -- Usuário do banco de dados que realizou a alteração
);

DELIMITER //

CREATE TRIGGER trg_film_update_audit
AFTER UPDATE ON film
FOR EACH ROW
BEGIN
    -- Insere um registro de auditoria APENAS SE o título ou a taxa de aluguel foram alterados
    IF OLD.title <> NEW.title OR OLD.rental_rate <> NEW.rental_rate THEN
        INSERT INTO film_audit_log (
            film_id,
            old_title,
            new_title,
            old_rental_rate,
            new_rental_rate,
            change_timestamp,
            changed_by_user
        )
        VALUES (
            OLD.film_id,           -- ID do filme (valor antigo é o mesmo que o novo)
            OLD.title,             -- Título antes da alteração
            NEW.title,             -- Título depois da alteração
            OLD.rental_rate,       -- Taxa de aluguel antes da alteração
            NEW.rental_rate,       -- Taxa de aluguel depois da alteração
            NOW(),                 -- Data e hora atual da alteração
            USER()                 -- Usuário que fez a alteração
        );
    END IF;
END //

DELIMITER ;
```

## Item 15 - Índices e Otimização (Indexes)

Conceito: O que é um Índice?
Em um banco de dados, um índice é uma estrutura de dados especial que melhora a velocidade das operações de recuperação de dados em uma tabela. Pense nele como um mapa de atalho ou um guia rápido para encontrar informações específicas.

#### Desafio: Atividade: Otimizando uma Consulta Lenta com Índices no Sakila

O departamento de marketing da Sakila está tentando identificar filmes que são alugados por clientes de cidades específicas para campanhas direcionadas. No entanto, o relatório que eles usam para isso está extremamente lento, especialmente ao lidar com a vasta quantidade de aluguéis e dados de clientes.

Você, como especialista em banco de dados, foi solicitado a investigar o problema e otimizar a consulta.

```sql
SELECT
    f.title,
    c.first_name,
    c.last_name,
    cy.city,
    r.rental_date
FROM
    rental AS r
JOIN
    inventory AS i ON r.inventory_id = i.inventory_id
JOIN
    film AS f ON i.film_id = f.film_id
JOIN
    customer AS c ON r.customer_id = c.customer_id
JOIN
    address AS a ON c.address_id = a.address_id
JOIN
    city AS cy ON a.city_id = cy.city_id
WHERE
    cy.city = 'London'
ORDER BY
    r.rental_date DESC;

EXPLAIN SELECT
    f.title,
    c.first_name,
    c.last_name,
    cy.city,
    r.rental_date
FROM
    rental AS r
JOIN
    inventory AS i ON r.inventory_id = i.inventory_id
JOIN
    film AS f ON i.film_id = f.film_id
JOIN
    customer AS c ON r.customer_id = c.customer_id
JOIN
    address AS a ON c.address_id = a.address_id
JOIN
    city AS cy ON a.city_id = cy.city_id
WHERE
    cy.city = 'London'
ORDER BY
    r.rental_date DESC;

    SELECT
    f.title,
    c.first_name,
    c.last_name,
    cy.city,
    r.rental_date
FROM
    rental AS r
JOIN
    inventory AS i ON r.inventory_id = i.inventory_id
JOIN
    film AS f ON i.film_id = f.film_id
JOIN
    customer AS c ON r.customer_id = c.customer_id
JOIN
    address AS a ON c.address_id = a.address_id
JOIN
    city AS cy ON a.city_id = cy.city_id
WHERE
    cy.city = 'London'
ORDER BY
    r.rental_date DESC;

EXPLAIN SELECT
    f.title,
    c.first_name,
    c.last_name,
    cy.city,
    r.rental_date
FROM
    rental AS r
JOIN
    inventory AS i ON r.inventory_id = i.inventory_id
JOIN
    film AS f ON i.film_id = f.film_id
JOIN
    customer AS c ON r.customer_id = c.customer_id
JOIN
    address AS a ON c.address_id = a.address_id
JOIN
    city AS cy ON a.city_id = cy.city_id
WHERE
    cy.city = 'London'
ORDER BY
    r.rental_date DESC;
```
