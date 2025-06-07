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
