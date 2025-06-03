**Testes e Exemplos de Uso – Banco “TechPoint”**

---

Este documento apresenta scripts de teste e exemplos de uso das principais rotinas do banco de dados “TechPoint”. Os exemplos incluem:

1. Inserção de Clientes (via `cria_cliente`)
2. Inserção de Fornecedores (via `cria_fornecedor`)
3. Criação de Pedido e Itens (via `realiza_venda`), demonstrando o disparo da trigger de estoque
4. Uso das Views e SELECTs para relatórios

Para cada exemplo, estão comentados os passos e, quando aplicável, o resultado esperado (estimado) em tabelas.

---

## 1. Inserção de Clientes (via `cria_cliente`)

```sql
-- Exemplo 1.1: Inserir um cliente válido
CALL cria_cliente(
  'Carlos Eduardo',        -- p_nome
  '57475235033',           -- p_cpf (11 dígitos válidos)
  'carlos.eduardo@exemplo.com',  -- p_email
  '11-91234-5678',         -- p_tel
  'Rua das Laranjeiras, 123 - São Paulo'  -- p_end
);

-- Espera-se sucesso: um novo registro em cliente foi criado.
-- Verificação (SELECT após a inserção):
SELECT id, nome, cpf, email, telefone, endereco, ativo
FROM cliente
WHERE cpf = '57475235033';

-- Resultado esperado (apenas como exemplo ilustrativo):
-- +----+-----------------+------------+------------------------------+--------------+-------------------------------------------+------+
-- | id | nome            | cpf        | email                        | telefone     | endereco                                  | ativo|
-- +----+-----------------+------------+------------------------------+--------------+-------------------------------------------+------+
-- |  7 | Carlos Eduardo  | 57475235033| carlos.eduardo@exemplo.com   | 11-91234-5678| Rua das Laranjeiras, 123 - São Paulo      |    1 |
-- +----+-----------------+------------+------------------------------+--------------+-------------------------------------------+------+

-- Exemplo 1.2: Tentar inserir um cliente com CPF inválido
CALL cria_cliente(
  'Fernanda Silva',
  '00000000000',            -- Todos os dígitos iguais → inválido
  'fernanda.silva@exemplo.com',
  '21-98765-4321',
  'Av. Brasil, 500 - Rio de Janeiro'
);

-- Resultado esperado:
-- ERRO: SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CPF inválido'

-- Conclusão: a procedure impede inserções de CPFs inválidos.
```

---

## 2. Inserção de Fornecedores (via `cria_fornecedor`)

```sql
-- Exemplo 2.1: Inserir um fornecedor pessoa jurídica (CNPJ válido)
CALL cria_fornecedor(
  'Tech Solutions LTDA',   -- p_nome
  '12345678000195',        -- p_cpf_cnpj (14 dígitos válidos)
  '31-99876-5432',         -- p_tel
  'Av. Afonso Pena, 1000 - Belo Horizonte'
);

-- Verificação:
SELECT id, nome, cpf_cnpj, telefone, endereco
FROM fornecedor
WHERE cpf_cnpj = '12345678000195';

-- Saída esperada:
-- +----+-----------------------+----------------+--------------+-----------------------------------------+
-- | id | nome                  | cpf_cnpj       | telefone     | endereco                                |
-- +----+-----------------------+----------------+--------------+-----------------------------------------+
-- |  4 | Tech Solutions LTDA   | 12345678000195 | 31-99876-5432| Av. Afonso Pena, 1000 - Belo Horizonte  |
-- +----+-----------------------+----------------+--------------+-----------------------------------------+

-- Exemplo 2.2: Inserir um fornecedor pessoa física (CPF válido)
CALL cria_fornecedor(
  'Ana Beatriz Costa',    -- p_nome
  '54413784090',          -- p_cpf_cnpj (11 dígitos válidos)
  '41-97654-3210',        -- p_tel
  'Rua XV de Novembro, 200 - Curitiba'
);

-- Verificação:
SELECT id, nome, cpf_cnpj, telefone, endereco
FROM fornecedor
WHERE cpf_cnpj = '54413784090';

-- Saída esperada:
-- +----+----------------------+--------------+--------------+---------------------------------------+
-- | id | nome                 | cpf_cnpj     | telefone     | endereco                              |
-- +----+----------------------+--------------+--------------+---------------------------------------+
-- |  5 | Ana Beatriz Costa    | 54413784090  | 41-97654-3210| Rua XV de Novembro, 200 - Curitiba   |
-- +----+----------------------+--------------+--------------+---------------------------------------+

-- Exemplo 2.3: Tentar inserir fornecedor com CNPJ inválido (dígitos errados)
CALL cria_fornecedor(
  'Fornecedor Incorreto',
  '11111111111111',  -- Todos os dígitos iguais → CNPJ inválido
  '61-91234-5678',
  'Setor Comercial Norte, Brasília'
);

-- Saída esperada:
-- ERRO: SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CNPJ inválido'
```

---

## 3. Criação de Pedido e Itens (via `realiza_venda`) e Trigger de Estoque

### 3.1. Populando o Estoque Inicial

Para demonstrar corretamente a rotina de venda, vamos inserir alguns produtos e um cliente adicional.

```sql
-- Inserir produto extra para teste
INSERT INTO produto (nome, descricao, preco, estoque, fornecedor_id)
VALUES
('Headset Gamer', 'Headset com microfone e LED', 15000, 20, 5);

-- Inserir outro cliente
CALL cria_cliente(
  'Mariana Oliveira',
  '71730727000',
  'mariana.oliveira@exemplo.com',
  '51-91234-0000',
  'Rua Sete de Setembro, 50 - Porto Alegre'
);
```

### 3.2. Exemplo de Venda com Produtos e Serviços

Suponha que o cliente “Mariana Oliveira” (ID 8, conforme exemplo) queira comprar:

- 2 unidades do produto “Notebook Acer” (produto_id = 1)
- 1 unidade do produto “Headset Gamer” (produto_id = 6)
- 1 sessão do serviço “Limpeza Física” (servico_id = 3)

Montamos um JSON com esses itens:

```sql
SET @itens_json = '[
  {"produto_id": 1, "servico_id": null, "quantidade": 2},
  {"produto_id": 6, "servico_id": null, "quantidade": 1},
  {"produto_id": null, "servico_id": 3, "quantidade": 1}
]';
```

Agora, chamamos a procedure para registrar a venda. Suponha que o operador que registra seja o usuário de ID 2 (Ana Paula).

```sql
CALL realiza_venda(
  8,        -- p_cliente_id = Mariana Oliveira (ID 8)
  2,        -- p_usuario_id = Ana Paula (ID 2)
  @itens_json
);
```

#### 3.2.1. Efeitos Esperados:

1. **Tabela `pedido`**

   - Será criado um novo registro em `pedido` com:

     - `cliente_id = 8`
     - `usuario_id = 2`
     - `data_pedido = TIMESTAMP atual`
     - `total = 0` (init)

   - Após inserir itens, o campo `total` será atualizado para:

     ```
     (2 × 350 000) + (1 × 15 000) + (1 × 3 000) = 700 000 + 15 000 + 3 000 = 718 000 (centavos)
     ```

   **Verificação:**

   ```sql
   SELECT id, cliente_id, usuario_id, data_pedido, total
   FROM pedido
   WHERE id = 1;
   ```

   **Saída esperada (exemplo):**

   ```
   +----+------------+------------+---------------------+-------+
   | id | cliente_id | usuario_id | data_pedido         | total |
   +----+------------+------------+---------------------+-------+
   |  1 |          8 |          2 | 2025-06-01 14:30:00 | 718000|
   +----+------------+------------+---------------------+-------+
   ```

2. **Tabela `item_pedido`**

   - Serão inseridos três registros:

     - Item 1: `pedido_id = 1`, `produto_id = 1`, `servico_id = NULL`, `quantidade = 2`, `preco_unitario = 350000`
     - Item 2: `pedido_id = 1`, `produto_id = 6`, `servico_id = NULL`, `quantidade = 1`, `preco_unitario = 15000`
     - Item 3: `pedido_id = 1`, `produto_id = NULL`, `servico_id = 3`, `quantidade = 1`, `preco_unitario = 3000`

   **Verificação:**

   ```sql
   SELECT id, pedido_id, produto_id, servico_id, quantidade, preco_unitario
   FROM item_pedido
   WHERE pedido_id = 1
   ORDER BY id;
   ```

   **Saída esperada:**

   ```
   +----+-----------+------------+------------+-----------+---------------+
   | id | pedido_id | produto_id | servico_id | quantidade| preco_unitario|
   +----+-----------+------------+------------+-----------+---------------+
   | 1 |        1 |          1 |       NULL |         2 |        350000 |
   | 2 |        1 |          6 |       NULL |         1 |         15000 |
   | 3 |        1 |       NULL |          3 |         1 |          3000 |
   +----+-----------+------------+------------+-----------+---------------+
   ```

3. **Trigger `trg_item_pedido_after_insert` e Controle de Estoque**

   - Ao inserir cada item de produto (IDs 1 e 2), a trigger será disparada:

     - Para `produto_id = 1` (Notebook Acer), supomos que o estoque anterior era 10. Será chamada `atualiza_estoque(1, 10 - 2 = 8)`, gerando:

       1. `UPDATE produto SET estoque = 8 WHERE id = 1;`
       2. `INSERT INTO estoque_log (produto_id, quantidade_anterior, quantidade_nova) VALUES (1, 10, 8);`

     - Para `produto_id = 6` (Headset Gamer), estoque anterior era 20. Será chamada `atualiza_estoque(6, 20 - 1 = 19)`, gerando:

       1. `UPDATE produto SET estoque = 19 WHERE id = 6;`
       2. `INSERT INTO estoque_log (produto_id, quantidade_anterior, quantidade_nova) VALUES (6, 20, 19);`

   **Verificação da Tabela `produto` (após venda):**

   ```sql
   SELECT id, nome, preco, estoque
   FROM produto
   WHERE id IN (1, 6);
   ```

   **Saída esperada:**

   ```
   +----+---------------+-------+--------+
   | id | nome          | preco | estoque|
   +----+---------------+-------+--------+
   |  1 | Notebook Acer |350000 |      8 |
   |  6 | Headset Gamer |15000  |     19 |
   +----+---------------+-------+--------+
   ```

   **Verificação da Tabela `estoque_log`:**

   ```sql
   SELECT id, produto_id, quantidade_anterior, quantidade_nova, data_atualizacao
   FROM estoque_log
   WHERE produto_id IN (1, 6)
   ORDER BY id DESC
   LIMIT 2;
   ```

   _(Exemplo dos dois últimos registros gerados)_
   **Saída esperada (exemplo):**

   ```
   +----+------------+-------------------+----------------+---------------------+
   | id | produto_id | quantidade_anterior| quantidade_nova| data_atualizacao    |
   +----+------------+-------------------+----------------+---------------------+
   | 47 |          6 |                20 |             19 | 2025-06-01 14:30:02 |
   | 46 |          1 |                10 |              8 | 2025-06-01 14:30:01 |
   +----+------------+-------------------+----------------+---------------------+
   ```

4. **Atualização do Campo `total` em `pedido`**

   - Após inserir itens, a procedure `realiza_venda` calcula o total (via `calcula_total_pedido(10)`) e atualiza `pedido.total` para 718000.
   - A verificação desse valor já foi mostrada no item 3.2.1.

---

## 4. Uso das Views e SELECTs para Relatórios

### 4.1. Produto e Serviço Mais Vendidos

1. **Produtos Mais Vendidos**

   ```sql
   SELECT *
   FROM vw_produtos_mais_vendidos
   LIMIT 5;
   ```

   - Exibe os 5 produtos com maior quantidade vendida (coluna `total_qtd`).
   - Exemplo de saída:

     ```
     +------------+-----------------+-----------+
     | produto_id | produto_nome    | total_qtd |
     +------------+-----------------+-----------+
     |          1 | Notebook Acer   |         5 |
     |          3 | Mouse Logitech  |         3 |
     |          6 | Headset Gamer   |         1 |
     +------------+-----------------+-----------+
     ```

2. **Serviços Mais Vendidos**

   ```sql
   SELECT *
   FROM vw_servicos_mais_vendidos
   LIMIT 5;
   ```

   - Exibe os 5 serviços com maior quantidade vendida.
   - Exemplo de saída:

     ```
     +------------+-------------------------+-----------+
     | servico_id | servico_nome            | total_qtd |
     +------------+-------------------------+-----------+
     |          3 | Limpeza Física          |         4 |
     |          1 | Instalação de Software  |         2 |
     |          2 | Formatação de PC        |         1 |
     +------------+-------------------------+-----------+
     ```

### 4.2. Vendas por Usuário (Operador)

```sql
SELECT *
FROM vw_vendas_por_usuario;
```

- Retorna, para cada operador (usuário), o total de vendas somadas (`total_vendas`).
- Exemplo de saída:

  ```
  +------------+---------------+--------------+
  | usuario_id | usuario_nome  | total_vendas |
  +------------+---------------+--------------+
  |          2 | Ana Paula     |       1 500 000 |
  |          1 | Luciano Pereira|      950 000 |
  |          0 | Sem Operador  |       300 000 |
  |          3 | Bruno Costa   |       210 000 |
  +------------+---------------+--------------+
  ```

### 4.3. Total Gasto por Cliente

```sql
SELECT *
FROM vw_clientes_total_gasto
LIMIT 10;
```

- Exibe, para cada cliente ativo, o total gasto acumulado.
- Ordena decrescentemente, mostrando os maiores gastadores primeiro.
- Exemplo de saída:

  ```
  +------------+----------------------+-------------+
  | cliente_id | cliente_nome         | total_gasto |
  +------------+----------------------+-------------+
  |          8 | Mariana Oliveira     |      718 000|
  |          1 | João Silva           |      500 000|
  |          2 | Maria Fernanda       |      450 000|
  |          7 | Carlos Eduardo       |      320 000|
  +------------+----------------------+-------------+
  ```

### 4.4. Consultas Diretas em Tabelas

1. **Exibir todos os clientes ativos**

   ```sql
   CALL busca_clientes_ativos();
   ```

   _Equivalente a:_

   ```sql
   SELECT *
   FROM cliente
   WHERE ativo = TRUE;
   ```

2. **Exibir todos os produtos sem estoque**

   ```sql
   CALL busca_produtos_sem_estoque();
   ```

   _Equivalente a:_

   ```sql
   SELECT *
   FROM produto
   WHERE estoque = 0;
   ```

3. **Exibir pedidos realizados por um determinado usuário (ID = 2)**

   ```sql
   CALL busca_pedidos_por_usuario(2);
   ```

   _Equivalente a:_

   ```sql
   SELECT *
   FROM pedido
   WHERE usuario_id = 2;
   ```

4. **Exibir pedidos de um cliente específico (ID = 8)**

   ```sql
   CALL busca_pedidos_por_cliente(8);
   ```

   _Equivalente a:_

   ```sql
   SELECT *
   FROM pedido
   WHERE cliente_id = 8;
   ```

## 5. Edição e Auditoria via `usuario_log`

Este item demonstra como o sistema registra automaticamente alterações em usuários, produtos e serviços na tabela `usuario_log`, no formato CSV, por meio de triggers (`AFTER UPDATE`). O log permite auditoria completa das alterações realizadas.

---

### 5.1. Atualização de Perfil de Usuário

```sql
-- Exemplo 5.1: Atualizar nome e endereço de um usuário
UPDATE usuario
SET nome = 'Luciano P. Silva',
    endereco = 'Rua Alpha, 101 - Campinas'
WHERE id = 1;
```

**Efeito Esperado:**

* A trigger `trg_usuario_after_update` será ativada.
* Será inserido um registro na tabela `usuario_log` com:

  * `usuario_id = 1`
  * `tipo = 'atualizacao_perfil'`
  * `descricao` com os valores antigos e novos no formato CSV.

**Verificação:**

```sql
SELECT id, usuario_id, tipo, descricao
FROM usuario_log
WHERE tipo = 'atualizacao_perfil'
ORDER BY id DESC
LIMIT 1;
```

**Exemplo de Saída:**

```
+----+-------------+---------------------+--------------------------------------------------------------------------+
| id | usuario_id  | tipo                | descricao                                                                |
+----+-------------+---------------------+--------------------------------------------------------------------------+
| 42 |           1 | atualizacao_perfil  | id,nome,email,cpf_cnpj,endereco,ativo\n1,Luciano Pereira,...             |
+----+-------------+---------------------+--------------------------------------------------------------------------+
```

---

### 5.2. Atualização de Produto

```sql
-- Exemplo 5.2: Atualizar preço e ativar um produto
UPDATE produto
SET preco = 370000,
    ativo = TRUE
WHERE id = 1;
```

**Efeito Esperado:**

* A trigger `trg_produto_after_update` será ativada.
* Será gerado um log em `usuario_log` com:

  * `usuario_id = 0` (sistema ou operador indefinido)
  * `tipo = 'atualizacao_produto'`
  * CSV com dados antigos e novos.

**Verificação:**

```sql
SELECT id, usuario_id, tipo, descricao
FROM usuario_log
WHERE tipo = 'atualizacao_produto'
ORDER BY id DESC
LIMIT 1;
```

---

### 5.3. Atualização de Serviço

```sql
-- Exemplo 5.3: Alterar nome e descrição de um serviço
UPDATE servico
SET nome = 'Reparo de Hardware Avançado',
    descricao = 'Substituição de peças e manutenção especializada'
WHERE id = 4;
```

**Efeito Esperado:**

* A trigger `trg_servico_after_update` será acionada.
* Registro criado em `usuario_log` com:

  * `usuario_id = 0`
  * `tipo = 'atualizacao_servico'`
  * Campo `descricao` com CSV de alterações.

---

### 5.4. Verificação Completa do Log

```sql
SELECT *
FROM usuario_log
ORDER BY id DESC
LIMIT 10;
```

**Colunas disponíveis:**

* `id`: ID do log
* `usuario_id`: Quem realizou a ação (ou `0`)
* `tipo`: Tipo de alteração (perfil/produto/serviço)
* `descricao`: CSV com antes/depois
