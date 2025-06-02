**Documentação Descritiva das Rotinas (Funções, Procedures, Triggers e Views)**

---

## Sumário

1. [Funções](#funções)
   1.1. `valida_cpf`
   1.2. `valida_cnpj`
   1.3. `calcula_total_pedido`
   1.4. `format_csv_string`
   1.5. `monta_csv_log`

2. [Procedures](#procedures)
   2.1. `cria_cliente`
   2.2. `cria_usuario`
   2.3. `cria_fornecedor`
   2.4. `atualiza_estoque`
   2.5. `realiza_venda`
   2.6. Procedures de Busca
     2.6.1. `busca_produtos_com_estoque_ativos`
     2.6.2. `busca_produtos_ativos_sem_estoque`
     2.6.3. `busca_clientes_ativos`
     2.6.4. `busca_usuarios_ativos`
     2.6.5. `busca_pedidos_por_usuario`
     2.6.6. `busca_pedidos_por_cliente`
     2.6.7. `busca_produtos_inativos`
     2.6.8. `busca_produtos_sem_estoque`

3. [Triggers](#triggers)
   3.1. `trg_usuario_after_update`
   3.2. `trg_produto_after_update`
   3.3. `trg_servico_after_update`
   3.4. `trg_item_pedido_after_insert`

4. [Views](#views)
   4.1. `vw_servicos_mais_vendidos`
   4.2. `vw_produtos_mais_vendidos`
   4.3. `vw_vendas_por_usuario`
   4.4. `vw_clientes_total_gasto`

---

## 1. Funções <a name="funções"></a>

### 1.1. Função: `valida_cpf`

- **Definição**

  ```sql
  create function valida_cpf(p_cpf char(11))
  returns boolean
  deterministic
  ```

- **Parâmetro**

  - `p_cpf` (CHAR(11)): sequência de 11 dígitos numéricos representando o CPF sem pontuação (por exemplo, `'12345678909'`).

- **Retorno**

  - BOOLEAN:

    - `TRUE` se o CPF for válido;
    - `FALSE` caso contrário.

- **Uso Típico**

  - É invocada antes de inserir ou atualizar registros que contenham CPF (tabelas `cliente`, `usuario`, `fornecedor`).
  - Exemplo em uma procedure:

    ```sql
    IF NOT valida_cpf('12345678909') THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CPF inválido';
    END IF;
    ```

---

### 1.2. Função: `valida_cnpj`

- **Definição**

  ```sql
  create function valida_cnpj(cnpj char(14))
  returns boolean
  deterministic
  ```

- **Parâmetro**

  - `cnpj` (CHAR(14)): sequência de 14 dígitos numéricos representando o CNPJ sem pontuação (por exemplo, `'12345678000195'`).

- **Retorno**

  - BOOLEAN:

    - `TRUE` se o CNPJ for válido;
    - `FALSE` caso contrário.

- **Uso Típico**

  - Aplicada sempre que um registro exige CNPJ válido (por exemplo, em `fornecedor` quando o campo tem 14 dígitos).
  - Exemplo de uso:

    ```sql
    IF NOT valida_cnpj('12345678000195') THEN
       SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CNPJ inválido';
    END IF;
    ```

---

### 1.3. Função: `calcula_total_pedido`

- **Definição**

  ```sql
  create function calcula_total_pedido(p_pedido_id int)
  returns int
  deterministic
  ```

- **Parâmetro**

  - `p_pedido_id` (INT): identificador do pedido cujos itens devem ser somados.

- **Retorno**

  - INT: valor total de todos os itens do pedido, em centavos. Se não houver itens, retorna 0.

- **Uso Típico**

  - Chamado ao final de uma rotina de venda/atualização de pedido para armazenar no campo `total` de `pedido`.
  - Por exemplo, dentro de uma procedure que insere itens de `item_pedido`, depois:

    ```sql
    UPDATE pedido
    SET total = calcula_total_pedido(v_pedido_id)
    WHERE id = v_pedido_id;
    ```

---

### 1.4. Função: `format_csv_string`

- **Definição**

  ```sql
  create function format_csv_string(p_value text)
  returns text
  deterministic
  ```

- **Parâmetro**

  - `p_value` (TEXT): string que será escapada para inclusão em formato CSV.

- **Retorno**

  - TEXT: a mesma string passada, mas com aspas duplas (`"`) duplicadas (`""`), garantindo conformidade com CSV.

- **Uso Típico**

  - Na montagem de descrições em CSV para logs de auditoria (em `usuario_log`), ao concatenar campos de texto no estilo:

    ```sql
    CONCAT('"', format_csv_string(campo_texto), '"')
    ```

---

### 1.5. Função: `monta_csv_log`

- **Definição**

  ```sql
  create function monta_csv(
    header text,
    old_values json,
    new_values json
  )
  returns text
  deterministic
  ```

- **Parâmetros**

  - `header` (TEXT): cabeçalho do CSV, contendo os nomes das colunas.
  - `old_values` (JSON): objeto JSON com os valores antigos dos campos.
  - `new_values` (JSON): objeto JSON com os novos valores dos campos.

- **Retorno**

  - TEXT: linha formatada no padrão CSV, unindo os quatro valores, onde `p_nome` e `p_descricao` vêm entre aspas e escapados (via `format_csv_string`).

- **Uso Típico**

  - Geração dinâmica de linhas CSV em triggers de auditoria que gravam estados antigos/novos de registros de `produto`, `servico`, ou `usuario`.

---

## 2. Procedures <a name="procedures"></a>

### 2.1. Procedure: `cria_cliente`

- **Definição**

  ```sql
  create procedure cria_cliente(
      p_nome varchar(150),
      p_cpf char(11),
      p_email varchar(150),
      p_tel varchar(20),
      p_end text
  )
  ```

- **Parâmetros**

  - `p_nome` (VARCHAR(150)): nome completo do cliente.
  - `p_cpf` (CHAR(11)): CPF de 11 dígitos.
  - `p_email` (VARCHAR(150)): e-mail do cliente.
  - `p_tel` (VARCHAR(20)): telefone (pode ser `NULL`).
  - `p_end` (TEXT): endereço (pode ser `NULL`).

---

### 2.2. Procedure: `cria_usuario`

- **Definição**

  ```sql
  create procedure cria_usuario(
      p_nome varchar(150),
      p_email varchar(150),
      p_cpf_cnpj varchar(14),
      p_end text
  )
  ```

- **Parâmetros**

  - `p_nome` (VARCHAR(150)): nome do usuário.
  - `p_email` (VARCHAR(150)): e-mail do usuário (login e contato).
  - `p_cpf_cnpj` (VARCHAR(14)): CPF (11 dígitos) ou CNPJ (14 dígitos).
  - `p_end` (TEXT): endereço (pode ser `NULL`).

---

### 2.3. Procedure: `cria_fornecedor`

- **Definição**

  ```sql
  create procedure cria_fornecedor(
      p_nome varchar(150),
      p_cpf_cnpj varchar(14),
      p_tel varchar(20),
      p_end text
  )
  ```

- **Parâmetros**

  - `p_nome` (VARCHAR(150)): nome ou razão social do fornecedor.
  - `p_cpf_cnpj` (VARCHAR(14)): CPF (11 dígitos) ou CNPJ (14 dígitos).
  - `p_tel` (VARCHAR(20)): telefone (pode ser `NULL`).
  - `p_end` (TEXT): endereço (pode ser `NULL`).

---

### 2.4. Procedure: `atualiza_estoque`

- **Definição**

  ```sql
  create procedure atualiza_estoque(
      p_produto_id int,
      p_nova_quantidade int
  )
  ```

- **Parâmetros**

  - `p_produto_id` (INT): ID do produto cujo estoque deve ser atualizado.
  - `p_nova_quantidade` (INT): nova quantidade de estoque (não deve ser negativa).

---

### 2.5. Procedure: `realiza_venda`

- **Definição**

  ```sql
  create procedure realiza_venda(
      p_cliente_id int,
      p_usuario_id int,
      p_itens_json longtext
  )
  ```

- **Parâmetros**

  - `p_cliente_id` (INT): ID do cliente que fará a compra.
  - `p_usuario_id` (INT): ID do usuário (operador) que registra a venda (pode ser `NULL`).
  - `p_itens_json` (LONGTEXT): representação em JSON de um array de itens, em que cada item contém campos:

    - `produto_id` (INT ou `null`),
    - `servico_id` (INT ou `null`),
    - `quantidade` (INT),
    - `preco_unitario` (INT em centavos).

  Exemplo de JSON:

  ```json
  [
    {
      "produto_id": 1,
      "servico_id": null,
      "quantidade": 2,
      "preco_unitario": 350000
    },
    {
      "produto_id": null,
      "servico_id": 2,
      "quantidade": 1,
      "preco_unitario": 8000
    }
  ]
  ```

---

### 2.6. Procedures de Busca

Estas procedures têm como objetivo retornar conjuntos de dados filtrados de forma recorrente, sem modificar o conteúdo do banco. Todas elas fazem `SELECT` simples em uma tabela ou junção, com cláusulas `WHERE` ou agregações, conforme descrito abaixo.

#### 2.6.1. `busca_produtos_com_estoque_ativos`

- **Definição**

  ```sql
  create procedure busca_produtos_com_estoque_ativos()
  ```

- **Descrição**

  - Retorna todos os produtos cuja coluna `ativo = TRUE` e `estoque > 0`.

#### 2.6.2. `busca_produtos_ativos_sem_estoque`

- **Definição**

  ```sql
  create procedure busca_produtos_ativos_sem_estoque()
  ```

- **Descrição**

  - Retorna produtos ativos (`ativo = TRUE`) que atualmente estão com `estoque = 0`.

#### 2.6.3. `busca_clientes_ativos`

- **Definição**

  ```sql
  create procedure busca_clientes_ativos()
  ```

- **Descrição**

  - Retorna todos os clientes cujo campo `ativo = TRUE`.

#### 2.6.4. `busca_usuarios_ativos`

- **Definição**

  ```sql
  create procedure busca_usuarios_ativos()
  ```

- **Descrição**

  - Retorna todos os usuários cujo campo `ativo = TRUE`.

#### 2.6.5. `busca_pedidos_por_usuario`

- **Definição**

  ```sql
  create procedure busca_pedidos_por_usuario(
      p_usuario_id int
  )
  ```

- **Parâmetro**

  - `p_usuario_id` (INT): ID do usuário (operador) para filtrar pedidos.

- **Descrição**

  - Retorna todos os registros da tabela `pedido` onde `usuario_id = p_usuario_id`.

#### 2.6.6. `busca_pedidos_por_cliente`

- **Definição**

  ```sql
  create procedure busca_pedidos_por_cliente(
      p_cliente_id int
  )
  ```

- **Parâmetro**

  - `p_cliente_id` (INT): ID do cliente cujas compras se deseja listar.

- **Descrição**

  - Retorna todos os pedidos associados a `cliente_id = p_cliente_id`.

#### 2.6.7. `busca_produtos_inativos`

- **Definição**

  ```sql
  create procedure busca_produtos_inativos()
  ```

- **Descrição**

  - Retorna produtos onde `ativo = FALSE`.
  - Útil para relatórios de catálogo ou ações de reativação.

#### 2.6.8. `busca_produtos_sem_estoque`

- **Definição**

  ```sql
  create procedure busca_produtos_sem_estoque()
  ```

- **Descrição**

  - Retorna produtos que atualmente têm `estoque = 0`, independentemente de estarem ativos ou não.
  - Pode ser usado antes de reabastecer ou inativar produtos.

---

## 3. Triggers <a name="triggers"></a>

### 3.1. Trigger: `trg_usuario_after_update`

- **Definição**

  ```sql
  create trigger trg_usuario_after_update
  after update on usuario
  for each row
  ```

- **Evento**

  - Disparada imediatamente **após** qualquer atualização (`UPDATE`) na tabela `usuario`.

---

### 3.2. Trigger: `trg_produto_after_update`

- **Definição**

  ```sql
  create trigger trg_produto_after_update
  after update on produto
  for each row
  ```

- **Evento**

  - Disparada **após** cada `UPDATE` na tabela `produto`.

### 3.3. Trigger: `trg_servico_after_update`

- **Definição**

  ```sql
  create trigger trg_servico_after_update
  after update on servico
  for each row
  ```

- **Evento**

  - Disparada **após** cada `UPDATE` na tabela `servico`.

---

### 3.4. Trigger: `trg_item_pedido_after_insert`

- **Definição**

  ```sql
  create trigger trg_item_pedido_after_insert
  after insert on item_pedido
  for each row
  ```

- **Evento**

  - Disparada **após** cada `INSERT` em `item_pedido`.

---

## 4. Views <a name="views"></a>

### 4.1. View: `vw_servicos_mais_vendidos`

- **Definição**

  ```sql
  create view vw_servicos_mais_vendidos as
  select
      s.id as servico_id,
      s.nome as servico_nome,
      sum(ip.quantidade) as total_qtd
  from servico s
  join item_pedido ip on ip.servico_id = s.id
  group by s.id, s.nome
  order by total_qtd desc;
  ```

- **Descrição**

  - Retorna a soma das quantidades vendidas (`SUM(ip.quantidade)`) para cada serviço.
  - Relaciona `servico` com `item_pedido` (somente itens onde `servico_id IS NOT NULL`).
  - Exibe as colunas:

    1. `servico_id`
    2. `servico_nome`
    3. `total_qtd` (total de unidades vendidas)

  - Ordena em ordem decrescente de `total_qtd`, colocando o serviço mais vendido no topo.

---

### 4.2. View: `vw_produtos_mais_vendidos`

- **Definição**

  ```sql
  create view vw_produtos_mais_vendidos as
  select
      p.id as produto_id,
      p.nome as produto_nome,
      sum(ip.quantidade) as total_qtd
  from produto p
  join item_pedido ip on ip.produto_id = p.id
  group by p.id, p.nome
  order by total_qtd desc;
  ```

- **Descrição**

  - Similar à view de serviços, mas referenciada a `produto`.
  - Agrupa por `p.id` e `p.nome`.
  - Colunas retornadas:

    1. `produto_id`
    2. `produto_nome`
    3. `total_qtd` (unidades vendidas)

  - Ordena decrescentemente por `total_qtd`.

---

### 4.3. View: `vw_vendas_por_usuario`

- **Definição**

  ```sql
  create view vw_vendas_por_usuario as
  select
      ifnull(u.id, 0) as usuario_id,
      ifnull(u.nome, 'Sem Operador') as usuario_nome,
      sum(p.total) as total_vendas
  from pedido p
  left join usuario u on p.usuario_id = u.id
  group by usuario_id, usuario_nome
  order by total_vendas desc;
  ```

- **Descrição**

  - Retorna o valor total de vendas (`SUM(p.total)`) agrupadas por usuário.
  - Usa `LEFT JOIN` para incluir pedidos sem `usuario_id` (operador nulo), atribuindo:

    - `usuario_id = 0`
    - `usuario_nome = 'Sem Operador'`

  - Colunas retornadas:

    1. `usuario_id` (0 quando não há operador)
    2. `usuario_nome` (“Sem Operador” para pedidos sem usuário)
    3. `total_vendas` (soma de todos os `total` de pedidos atribuídos a esse usuário)

  - Ordena por `total_vendas` decrescente, destacando o usuário que mais vendeu.

---

### 4.4. View: `vw_clientes_total_gasto`

- **Definição**

  ```sql
  create view vw_clientes_total_gasto as
  select
      c.id as cliente_id,
      c.nome as cliente_nome,
      sum(p.total) as total_gasto
  from cliente c
  join pedido p on p.cliente_id = c.id
  where c.ativo = true
  group by c.id, c.nome
  order by total_gasto desc;
  ```

- **Descrição**

  - Retorna o total gasto (`SUM(p.total)`) por cada cliente ativo (`c.ativo = TRUE`).
  - Agrupa por `c.id` e `c.nome`.
  - Colunas:

    1. `cliente_id`
    2. `cliente_nome`
    3. `total_gasto` (soma de todos os pedidos do cliente)

  - Ordena decrescente por `total_gasto` para destacar os principais clientes em gasto.
