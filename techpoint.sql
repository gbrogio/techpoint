-- ==========================================================
-- Comentários Detalhados do Script SQL
-- ==========================================================

-- ===================================================================
-- 1. Criação do Banco de Dados e Seleção do Contexto
-- ===================================================================

-- Remove o banco de dados “techpoint” caso exista previamente, garantindo
-- uma recriação limpa para testes
drop database if exists techpoint;

-- Cria o banco de dados “techpoint”, que armazenará todas as tabelas,
-- funções, procedures, triggers e views deste projeto
create database techpoint;

-- Seleciona o banco de dados “techpoint” para que os comandos subsequentes
-- sejam executados neste contexto
use techpoint;


-- ===================================================================
-- 2. Criação das Tabelas (Entidades Principais)
-- ===================================================================

-- -----------------------------------------------------------
-- 2.1. Tabela: cliente
-- -----------------------------------------------------------
-- Finalidade: Armazena informações de clientes (pessoas físicas)
-- Campos principais:
--   id      : Identificador único (PK, auto-increment)
--   nome    : Nome completo do cliente (obrigatório)
--   cpf     : CPF (11 dígitos, formato “XXXXXXXXXXX”), único e validado
--   email   : E-mail de contato, único para evitar duplicação
--   telefone: Telefone de contato (opcional)
--   endereco: Endereço completo (rua, cidade, estado, etc.) (opcional)
--   ativo   : Flag booleana que indica se o cliente está ativo no sistema
--             (TRUE = ativo, FALSE = inativo). Permite inativação lógica.
create table cliente (
    id int auto_increment primary key,
    nome varchar(150) not null,
    cpf char(11) not null unique,
    email varchar(150) not null unique,
    telefone varchar(20) null,
    endereco text null,
    ativo boolean not null default true
);

-- --------------------------------------------------------------------------------
-- 2.2. Tabela: usuario
-- --------------------------------------------------------------------------------
-- Finalidade: Armazena operadores internos do sistema (funcionários, cadastradores)
-- Campos principais:
--   id       : Identificador único (PK, auto-increment)
--   nome     : Nome completo do usuário (obrigatório)
--   email    : E-mail de login e contato, único para autenticação
--   cpf_cnpj : CPF (11 dígitos) ou CNPJ (14 dígitos), único e validado
--   endereco : Endereço completo (opcional)
--   ativo    : Flag booleana que indica se o usuário está ativo (TRUE = ativo,
--              FALSE = inativo). Utilizada para inativação lógica.
create table usuario (
    id int auto_increment primary key,
    nome varchar(150) not null,
    email varchar(150) not null unique,
    cpf_cnpj varchar(14) not null unique,
    endereco text null,
    ativo boolean not null default true
);

-- ----------------------------------------------------------------------------------------------------
-- 2.3. Tabela: usuario_log
-- ----------------------------------------------------------------------------------------------------
-- Finalidade: Registra histórico de alterações feitas por/para usuários, produtos e serviços
-- Campos principais:
--   id         : Identificador único do log (PK, auto-increment)
--   usuario_id : FK → usuario(id), identifica o usuário que realizou a ação
--   tipo       : Tipo de operação realizada:
--                - deleta_produto
--                - deleta_servico
--                - atualizacao_perfil
--                - atualizacao_produto
--                - atualizacao_servico
--   descricao  : Texto em formato CSV que armazena valores antes/depois da alteração
--                Exemplo: “produto_id,nome,descricao,preco\n1,Notebook A,Notebook 8GB,350000”
create table usuario_log (
    id int auto_increment primary key,
    usuario_id int not null,
    tipo enum('deleta_produto', 'deleta_servico', 'atualizacao_perfil', 'atualizacao_produto', 'atualizacao_servico') not null,
    descricao text null,
    foreign key (usuario_id) references usuario(id)
);

-- --------------------------------------------------------------------------------
-- 2.4. Tabela: fornecedor
-- --------------------------------------------------------------------------------
-- Finalidade: Armazena fornecedores de produtos e serviços (pessoas físicas ou jurídicas)
-- Campos principais:
--   id       : Identificador único (PK, auto-increment)
--   nome     : Nome completo ou razão social do fornecedor (obrigatório)
--   cpf_cnpj : CPF (11 dígitos) ou CNPJ (14 dígitos), único e validado
--   telefone : Telefone de contato (opcional)
--   endereco : Endereço completo do fornecedor (opcional)
create table fornecedor (
    id int auto_increment primary key,
    nome varchar(150) not null,
    cpf_cnpj varchar(14) not null unique,
    telefone varchar(20) null,
    endereco text null
);

-- --------------------------------------------------------------------------------
-- 2.5. Tabela: produto
-- --------------------------------------------------------------------------------
-- Finalidade: Armazena produtos físicos disponíveis para venda
-- Campos principais:
--   id       : Identificador único (PK, auto-increment)
--   nome     : Nome do produto (obrigatório)
--   descricao: Descrição detalhada do produto (opcional)
--   preco    : Preço unitário em centavos (int), não negativo
--   estoque  : Quantidade disponível em estoque (int), não negativo
--   ativo    : Flag booleana que indica se o produto está ativo (TRUE = ativo,
--              FALSE = inativo). Utilizada para inativação lógica.
create table produto (
    id int auto_increment primary key,
    nome varchar(100) not null,
    descricao text null,
    preco int not null check (preco >= 0),
    estoque int not null default 0 check (estoque >= 0),
    ativo boolean not null default true,
    fornecedor_id int not null,
    foreign key (fornecedor_id) references fornecedor(id)
);

-- --------------------------------------------------------------------------------
-- 2.6. Tabela: servico
-- --------------------------------------------------------------------------------
-- Finalidade: Armazena serviços (não físicos) oferecidos pela empresa
-- Campos principais:
--   id       : Identificador único (PK, auto-increment)
--   nome     : Nome do serviço (obrigatório)
--   descricao: Descrição detalhada do serviço (opcional)
--   preco    : Preço do serviço em centavos (int), não negativo
--   ativo    : Flag booleana que indica se o serviço está ativo (TRUE = ativo,
--              FALSE = inativo). Utilizada para inativação lógica.
create table servico (
    id int auto_increment primary key,
    nome varchar(100) not null,
    descricao text null,
    preco int not null check (preco >= 0),
    ativo boolean not null default true
);

-- --------------------------------------------------------------------------------
-- 2.7. Tabela: pedido
-- --------------------------------------------------------------------------------
-- Finalidade: Representa venda realizada, associada a um cliente e a um usuário (opcional)
-- Campos principais:
--   id         : Identificador único (PK, auto-increment)
--   cliente_id : FK → cliente(id), identifica quem fez a compra
--   usuario_id : FK → usuario(id), identifica o operador que registrou o pedido (pode ser NULL)
--   data_pedido: Timestamp de criação do pedido (automático)
--   total      : Valor total em centavos, calculado a partir dos itens. Não negativo.
create table pedido (
    id int auto_increment primary key,
    cliente_id int not null,
    usuario_id int null,
    data_pedido timestamp not null default current_timestamp,
    total int not null check (total >= 0),
    foreign key (cliente_id) references cliente(id),
    foreign key (usuario_id) references usuario(id)
);

-- --------------------------------------------------------------------------------
-- 2.8. Tabela: item_pedido
-- --------------------------------------------------------------------------------
-- Finalidade: Armazena cada item (produto ou serviço) que compõe um pedido
-- Campos principais:
--   id             : Identificador único do item (PK, auto-increment)
--   pedido_id      : FK → pedido(id). ON DELETE CASCADE garante remoção em cascata
--   produto_id     : FK → produto(id). Preenchido quando o item é um produto.
--   servico_id     : FK → servico(id). Preenchido quando o item é um serviço.
--   quantidade     : Quantidade vendida do item (int), deve ser > 0
--   preco_unitario : Preço unitário em centavos, no momento da venda. Não negativo.
-- Constraint extra:
--   chk_item_produto_servico garante que exatamente um entre produto_id e servico_id seja não-nulo.
create table item_pedido (
    id int auto_increment primary key,
    pedido_id int not null,
    produto_id int null,
    servico_id int null,
    quantidade int not null check (quantidade > 0),
    preco_unitario int not null check (preco_unitario >= 0),
    constraint chk_item_produto_servico check (
        (produto_id is not null and servico_id is null)
        or
        (produto_id is null and servico_id is not null)
    ),
    foreign key (pedido_id) references pedido(id) on delete cascade,
    foreign key (produto_id) references produto(id),
    foreign key (servico_id) references servico(id)
);

-- --------------------------------------------------------------------------------
-- 2.9. Tabela: estoque_log
-- --------------------------------------------------------------------------------
-- Finalidade: Registra histórico de alterações de estoque de produtos
-- Campos principais:
--   id                 : Identificador único do log (PK, auto-increment)
--   produto_id         : FK → produto(id), produto cujo estoque mudou
--   quantidade_anterior: Quantidade de estoque antes da atualização
--   quantidade_nova    : Quantidade de estoque após atualização
--   data_atualizacao   : Timestamp de quando a alteração foi realizada (automático)
create table estoque_log (
    id int auto_increment primary key,
    produto_id int not null,
    quantidade_anterior int not null,
    quantidade_nova int not null,
    data_atualizacao timestamp not null default current_timestamp,
    foreign key (produto_id) references produto(id)
);


-- ===================================================================
-- 3. População de Dados de Exemplo (Inserts)
-- ===================================================================

-- -----------------------------------------------------------
-- 3.1. Inserção de Clientes (dados para testar o relacionamento)
-- -----------------------------------------------------------
insert into cliente (nome, email, cpf, endereco) values
    ('joão silva', 'joao.silva@email.com', '12345678901', 'rua x, 100 - são paulo'),
    ('maria fernanda', 'maria.f@email.com', '23456789012', 'rua y, 200 - rio'),
    ('paula martins', 'paula.m@email.com', '22334455667', 'av y, 200 - salvador'),
    ('thiago rocha', 'thiago.r@email.com', '33445566778', 'rua z, 300 - recife'),
    ('larissa melo', 'larissa.m@email.com', '44556677889', 'av w, 400 - fortaleza'),
    ('rafael alves', 'rafael.a@email.com', '55667788990', 'rua v, 500 - manaus');

-- -----------------------------------------------------------
-- 3.2. Inserção de Usuários (operadores internos para testes)
-- -----------------------------------------------------------
insert into usuario (nome, email, cpf_cnpj, endereco) values
    ('luciano pereira', 'luciano.p@email.com', '11223344556', 'rua x, 100 - campinas'),
    ('ana paula',        'ana.p@example.com',      '22334455667', 'rua y, 200 - salvador'),
    ('bruno costa',      'bruno.c@example.com',    '33445566778', 'rua z, 300 - recife'),
    ('carla almeida',    'carla.a@example.com',    '44556677889', 'av w, 400 - fortaleza'),
    ('daniel silva',     'daniel.s@example.com',   '55667788990', 'rua v, 500 - manaus');

-- -----------------------------------------------------------
-- 3.3. Inserção de Fornecedores (dados para futuros testes de relacionamento)
-- -----------------------------------------------------------
insert into fornecedor (nome, cpf_cnpj, telefone, endereco) values
    ('Tech Supplies LTDA', '12345678000199', '11-98765-4321', 'av principal, 1000 - são paulo'),
    ('José da Silva',       '78945612300',    '21-97654-3210', 'rua das flores, 500 - rio de janeiro'),
    ('Infor Solutions ME',  '98765432000188', '31-96543-2109', 'av liberdade, 800 - belo horizonte');

-- -----------------------------------------------------------
-- 3.4. Inserção de Produtos (exemplos para alimentar o estoque)
-- -----------------------------------------------------------
insert into produto (nome, descricao, preco, estoque, fornecedor_id) values
    ('notebook acer', 'notebook com 8gb ram e 256gb ssd', 350000, 10, 1),
    ('smartphone samsung', 'galaxy com 128gb', 250000, 15, 1),
    ('mouse logitech', 'mouse sem fio', 7500, 50, 2),
    ('monitor lg', 'monitor 24 polegadas', 80000, 8, 3),
    ('teclado mecânico', 'teclado gamer com led', 12000, 20, 3);

-- -----------------------------------------------------------
-- 3.5. Inserção de Serviços (exemplos para mostrar venda de serviços)
-- -----------------------------------------------------------
insert into servico (nome, descricao, preco) values
    ('instalação de software', 'instalação e configuração de programas', 5000),
    ('formatação de pc', 'formatação completa e backup', 8000),
    ('limpeza física', 'limpeza de hardware interna', 3000),
    ('reparo de hardware', 'troca de peças danificadas', 15000),
    ('suporte técnico', 'atendimento remoto para suporte', 6000);


-- ===================================================================
-- 4. Criação de Funções Auxiliares
-- ===================================================================

-- -----------------------------------------------------------
-- 4.1. Função: valida_cpf
-- -----------------------------------------------------------
-- Objetivo: Validar um CPF de 11 dígitos de entrada (sem pontuação), retornando
--           TRUE se for válido, FALSE caso contrário.
-- Parâmetro:
--   p_cpf : CHAR(11) contendo apenas números (exemplo: '12345678909')
-- Lógica (resumida):
--   - Verifica se todos os dígitos são iguais (ex.: '11111111111' é inválido).
--   - Calcula dígitos verificadores (10º e 11º) através de operações de módulo 11.
--   - Compara com os dígitos verificadores fornecidos.
delimiter $$
create function valida_cpf(p_cpf char(11))
returns boolean
deterministic
begin
    declare s int default 0;
    declare i int default 0;
    declare d1 int default 0;
    declare d2 int default 0;
    declare resto int default 0;

    -- Se todos os caracteres forem iguais, já é inválido
    if p_cpf = '00000000000'
      or p_cpf = '11111111111'
      or p_cpf = '22222222222'
      or p_cpf = '33333333333'
      or p_cpf = '44444444444'
      or p_cpf = '55555555555'
      or p_cpf = '66666666666'
      or p_cpf = '77777777777'
      or p_cpf = '88888888888'
      or p_cpf = '99999999999' then
        return false;
    end if;

    -- Cálculo do primeiro dígito verificador
    set s = 0;
    set i = 0;
    while i < 9 do
        set s = s + (cast(substring(p_cpf, i+1, 1) as signed) * (10 - i));
        set i = i + 1;
    end while;
    set resto = mod(s, 11);
    if resto < 2 then
        set d1 = 0;
    else
        set d1 = 11 - resto;
    end if;

    -- Cálculo do segundo dígito verificador
    set s = 0;
    set i = 0;
    while i < 10 do
        set s = s + (cast(substring(p_cpf, i+1, 1) as signed) * (11 - i));
        set i = i + 1;
    end while;
    set resto = mod(s, 11);
    if resto < 2 then
        set d2 = 0;
    else
        set d2 = 11 - resto;
    end if;

    -- Compara dígitos calculados (d1,d2) com os dígitos 10 e 11 do CPF informado
    if cast(substring(p_cpf, 10, 1) as signed) = d1
       and cast(substring(p_cpf, 11, 1) as signed) = d2 then
        return true;
    end if;

    return false;
end $$

-- -----------------------------------------------------------
-- 4.2. Função: valida_cnpj
-- -----------------------------------------------------------
-- Objetivo: Validar um CNPJ de 14 dígitos de entrada (sem pontuação), retornando
--           TRUE se for válido, FALSE caso contrário.
-- Parâmetro:
--   cnpj : CHAR(14) contendo apenas números (exemplo: '12345678000195')
-- Lógica (resumida):
--   - Verifica se todos os dígitos são iguais (ex.: '00000000000000' é inválido).
--   - Calcula dígitos verificadores (13º e 14º) através de operações de módulo 11,
--     com pesos específicos.
--   - Compara com os dígitos verificadores fornecidos.
delimiter $$
create function valida_cnpj(cnpj char(14))
returns boolean
deterministic
begin
    declare soma int default 0;
    declare i int default 0;
    declare resto int default 0;
    declare d1 int default 0;
    declare d2 int default 0;
    declare peso int default 2;

    -- Se todos os caracteres forem iguais, inválido
    if cnpj = '00000000000000'
      or cnpj = '11111111111111'
      or cnpj = '22222222222222'
      or cnpj = '33333333333333'
      or cnpj = '44444444444444'
      or cnpj = '55555555555555'
      or cnpj = '66666666666666'
      or cnpj = '77777777777777'
      or cnpj = '88888888888888'
      or cnpj = '99999999999999' then
        return false;
    end if;

    -- Cálculo do primeiro dígito verificador
    set soma = 0;
    set peso = 2;
    set i = 11;
    while i >= 0 do
        set soma = soma + (cast(substring(cnpj, i+1, 1) as signed) * peso);
        set peso = peso + 1;
        if peso > 9 then
            set peso = 2;
        end if;
        set i = i - 1;
    end while;
    set resto = mod(soma, 11);
    if resto < 2 then
        set d1 = 0;
    else
        set d1 = 11 - resto;
    end if;

    -- Cálculo do segundo dígito verificador
    set soma = 0;
    set peso = 2;
    set i = 12;
    while i >= 0 do
        set soma = soma + (cast(substring(cnpj, i+1, 1) as signed) * peso);
        set peso = peso + 1;
        if peso > 9 then
            set peso = 2;
        end if;
        set i = i - 1;
    end while;
    set resto = mod(soma, 11);
    if resto < 2 then
        set d2 = 0;
    else
        set d2 = 11 - resto;
    end if;

    -- Compara dígitos calculados (d1,d2) com os dígitos 13 e 14 do CNPJ informado
    if cast(substring(cnpj, 13, 1) as signed) = d1
       and cast(substring(cnpj, 14, 1) as signed) = d2 then
        return true;
    end if;

    return false;
end $$
delimiter ;


-- -----------------------------------------------------------
-- 4.3. Função: calcula_total_pedido
-- -----------------------------------------------------------
-- Objetivo: Calcula o valor total de um pedido somando preço_unitário * quantidade
--           para todos os itens do pedido, retornando um inteiro (centavos).
-- Parâmetro:
--   p_pedido_id : ID do pedido a ser calculado
-- Lógica:
--   - Percorre todos os registros da tabela item_pedido vinculados ao pedido.
--   - Multiplica preco_unitario pela quantidade de cada item.
--   - Soma todos os valores e retorna o total.
delimiter $$
create function calcula_total_pedido(p_pedido_id int)
returns int
deterministic
begin
    declare total_pedido int default 0;
    select sum(preco_unitario * quantidade) into total_pedido
    from item_pedido
    where pedido_id = p_pedido_id;
    return ifnull(total_pedido, 0);
end $$
delimiter ;


-- -----------------------------------------------------------
-- 4.4. Função: format_csv_string
-- -----------------------------------------------------------
-- Objetivo: Formatar uma string de texto em CSV, escapando caracteres especiais
-- Parâmetro:
--   p_value : Texto a ser formatado (campo tipo TEXT)
-- Retorna: STRING com aspas duplas escapadas para uso em CSV
delimiter $$
create function format_csv_string(p_value text)
returns text
deterministic
begin
    -- Substitui aspas duplas por aspas duplas duplicadas para conformidade CSV
    return replace(p_value, '"', '""');
end $$
delimiter ;


-- -----------------------------------------------------------
-- 4.5. Função: monta_csv_log
-- -----------------------------------------------------------
-- Objetivo: Montar um CSV de alteração de registro, formatando os campos
--           para uso em logs de auditoria.
-- Parâmetros:
--   header : Cabeçalho do log (ex.: "produto_id,nome,descricao,preco")
--   old_values : Valores antigos (antes da alteração)
--   new_values : Valores novos (após a alteração)
-- Retorna: STRING no formato CSV: “id,”nome","descrição",preço”
delimiter $$
create function monta_csv_log(
    header text,
    old_values json,
    new_values json
)
returns text
deterministic
begin

    declare csv_log text default '';
    declare old_value text;
    declare new_value text;
    declare i int default 0;

    -- Monta o cabeçalho do CSV
    set csv_log = concat(header, '\n');

    -- Percorre os valores antigos e novos
    while i < json_length(old_values) do
        set old_value = json_unquote(json_extract(old_values, concat('$[', i, ']')));
        set new_value = json_unquote(json_extract(new_values, concat('$[', i, ']')));
        set csv_log = concat(csv_log, format_csv_string(old_value), ',', format_csv_string(new_value), '\n');
        set i = i + 1;
    end while;

    return csv_log;
    
end $$
delimiter ;


-- ===================================================================
-- 5. Criação de Procedures
-- ===================================================================

-- -----------------------------------------------------------
-- 5.1. Procedure: cria_cliente
-- -----------------------------------------------------------
-- Finalidade: Inserir um novo cliente, validando CPF antes de salvar.
-- Parâmetros:
--   p_nome   : Nome completo do cliente
--   p_cpf    : CPF (11 dígitos, sem pontuação)
--   p_email  : E-mail do cliente
--   p_tel    : Telefone (pode ser NULL)
--   p_end    : Endereço (pode ser NULL)
-- Lógica:
--   1. Verifica se valida_cpf(p_cpf) retorna TRUE.
--   2. Se FALSE, lança erro (deploy de SIGNAL) informando CPF inválido.
--   3. Se CPF válido, insere na tabela cliente com “ativo = TRUE”.
delimiter $$
create procedure cria_cliente(
    p_nome varchar(150),
    p_cpf char(11),
    p_email varchar(150),
    p_tel varchar(20),
    p_end text
)
begin
    if not valida_cpf(p_cpf) then
        signal sqlstate '45000' set message_text = 'CPF inválido';
    end if;
    insert into cliente (nome, cpf, email, telefone, endereco)
    values (p_nome, p_cpf, p_email, p_tel, p_end);
end $$
delimiter ;


-- -----------------------------------------------------------
-- 5.2. Procedure: cria_usuario
-- -----------------------------------------------------------
-- Finalidade: Inserir um novo usuário, validando CPF (se pessoa física) ou CNPJ
--             (se pessoa jurídica), antes de salvar.
-- Parâmetros:
--   p_nome    : Nome do usuário
--   p_email   : E-mail do usuário
--   p_cpf_cnpj: CPF (11 dígitos) ou CNPJ (14 dígitos) sem pontuação
--   p_end     : Endereço (pode ser NULL)
-- Lógica:
--   1. Se LENGTH(p_cpf_cnpj) = 11 → valida_cpf, senão se LENGTH = 14 → valida_cnpj;
--   2. Se inválido, SIGNAL de erro “CPF/CNPJ inválido”;
--   3. Se válido, insere na tabela usuario com “ativo = TRUE”.
delimiter $$
create procedure cria_usuario(
    p_nome varchar(150),
    p_email varchar(150),
    p_cpf_cnpj varchar(14),
    p_end text
)
begin
    if length(p_cpf_cnpj) = 11 then
        if not valida_cpf(p_cpf_cnpj) then
            signal sqlstate '45000' set message_text = 'CPF inválido';
        end if;
    elseif length(p_cpf_cnpj) = 14 then
        if not valida_cnpj(p_cpf_cnpj) then
            signal sqlstate '45000' set message_text = 'CNPJ inválido';
        end if;
    else
        signal sqlstate '45000' set message_text = 'Tamanho de CPF/CNPJ inválido';
    end if;
    insert into usuario (nome, email, cpf_cnpj, endereco)
    values (p_nome, p_email, p_cpf_cnpj, p_end);
end $$
delimiter ;


-- -----------------------------------------------------------
-- 5.3. Procedure: cria_fornecedor
-- -----------------------------------------------------------
-- Finalidade: Inserir um novo fornecedor (pessoa física ou jurídica), validando CPF
--             ou CNPJ antes de salvar.
-- Parâmetros:
--   p_nome    : Nome ou razão social do fornecedor
--   p_cpf_cnpj: CPF (11 dígitos) ou CNPJ (14 dígitos) sem pontuação
--   p_tel     : Telefone (pode ser NULL)
--   p_end     : Endereço (pode ser NULL)
-- Lógica:
--   1. Verifica tamanho de p_cpf_cnpj (11 ou 14) e usa valida_cpf ou valida_cnpj;
--   2. Se inválido, SIGNAL de erro “CPF/CNPJ inválido”;
--   3. Se válido, insere na tabela fornecedor.
delimiter $$
create procedure cria_fornecedor(
    p_nome varchar(150),
    p_cpf_cnpj varchar(14),
    p_tel varchar(20),
    p_end text
)
begin
    if length(p_cpf_cnpj) = 11 then
        if not valida_cpf(p_cpf_cnpj) then
            signal sqlstate '45000' set message_text = 'CPF inválido';
        end if;
    elseif length(p_cpf_cnpj) = 14 then
        if not valida_cnpj(p_cpf_cnpj) then
            signal sqlstate '45000' set message_text = 'CNPJ inválido';
        end if;
    else
        signal sqlstate '45000' set message_text = 'Tamanho de CPF/CNPJ inválido';
    end if;
    insert into fornecedor (nome, cpf_cnpj, telefone, endereco)
    values (p_nome, p_cpf_cnpj, p_tel, p_end);
end $$
delimiter ;


-- -----------------------------------------------------------
-- 5.4. Procedure: atualiza_estoque
-- -----------------------------------------------------------
-- Finalidade: Atualizar a quantidade de estoque de um produto e gerar
--             registro de log na tabela estoque_log.
-- Parâmetros:
--   p_produto_id        : ID do produto a ser atualizado
--   p_nova_quantidade   : Valor final do estoque (substitui o anterior)
-- Lógica:
--   1. Seleciona a quantidade atual do produto em “quantidade_anterior”;
--   2. Atualiza a tabela produto, definindo estoque = p_nova_quantidade;
--   3. Insere registro em estoque_log (produto_id, quantidade_anterior,
--      quantidade_nova, data_atualizacao).
delimiter $$
create procedure atualiza_estoque(
    p_produto_id int,
    p_nova_quantidade int
)
begin
    declare qtd_anterior int;
    select estoque into qtd_anterior
    from produto
    where id = p_produto_id;

    update produto
    set estoque = p_nova_quantidade
    where id = p_produto_id;

    insert into estoque_log (produto_id, quantidade_anterior, quantidade_nova)
    values (p_produto_id, qtd_anterior, p_nova_quantidade);
end $$
delimiter ;


-- -----------------------------------------------------------
-- 5.5. Procedure: realiza_venda
-- -----------------------------------------------------------
-- Finalidade: Realizar todo o fluxo de venda de um pedido, incluindo:
--   1. Criação do registro na tabela pedido (associado a cliente e usuário)
--   2. Inserção de itens em item_pedido (produtos/serviços)
--   3. Para cada item de produto, chamar atualiza_estoque e gerar log
--   4. Atualizar o campo total de pedido com o valor calculado (calcula_total_pedido)
-- Parâmetros:
--   p_cliente_id : ID do cliente que está comprando
--   p_usuario_id : ID do usuário que está registrando o pedido (pode ser NULL)
--   p_itens_json : JSON contendo lista de itens. Exemplo:
--       '[{"produto_id":1,"servico_id":null,"quantidade":2}, …]'
-- Lógica resumida:
--   - Insere nova linha em pedido com total = 0 temporariamente
--   - Usa JSON_TABLE para percorrer array JSON e inserir em item_pedido cada registro
--   - Se produto_id não for nulo, chama atualiza_estoque para diminuir o estoque
--   - Calcula total final com calcula_total_pedido e atualiza o campo total do pedido
delimiter $$
create procedure realiza_venda(
    p_cliente_id int,
    p_usuario_id int,
    p_itens_json longtext
)
begin
    declare v_pedido_id int;

    -- Cria tabela temporária para armazenar os itens com preço
    create temporary table if not exists tmp_itens (
        produto_id int,
        servico_id int,
        quantidade int,
        preco_unitario int
    );

    -- Insere os itens já com o preço calculado
    insert into tmp_itens (produto_id, servico_id, quantidade, preco_unitario)
    select
        ijt.produto_id,
        ijt.servico_id,
        ijt.quantidade,
        case
            when ijt.produto_id is not null then (select preco from produto where id = ijt.produto_id)
            else (select preco from servico where id = ijt.servico_id)
        end as preco_unitario
    from json_table(
        p_itens_json,
        '$[*]' columns (
            produto_id int path '$.produto_id',
            servico_id int path '$.servico_id',
            quantidade int path '$.quantidade'
        )
    ) as ijt;

    -- Verifica se há produto com estoque insuficiente
    if exists (
        select 1
        from tmp_itens ti
        join produto p on ti.produto_id = p.id
        where ti.produto_id is not null
          and ti.quantidade > p.estoque
    ) then
        signal sqlstate '45000' set message_text = 'Erro: Produto com estoque insuficiente para a venda.';
    end if;

    -- 1. Insere pedido com total = 0 temporário
    insert into pedido (cliente_id, usuario_id, total)
    values (p_cliente_id, p_usuario_id, 0);
    set v_pedido_id = last_insert_id();

    -- 2. Insere os itens a partir do JSON
    insert into item_pedido (pedido_id, produto_id, servico_id, quantidade, preco_unitario)
    select
        v_pedido_id, produto_id, servico_id, quantidade, preco_unitario
    from tmp_itens;

    -- 3. A trigger trg_item_pedido_after_insert cuida da atualização de estoque
    -- Portanto, nenhuma lógica adicional de estoque aqui

    -- 4. Atualiza o total do pedido
    update pedido
    set total = calcula_total_pedido(v_pedido_id)
    where id = v_pedido_id;

    -- Limpa a tabela temporária
    drop temporary table if exists tmp_itens;
end $$
delimiter ;


-- -----------------------------------------------------------
-- 5.6. Procedures de Busca (Consultas com critérios pré-definidos)
-- -----------------------------------------------------------
-- Estas procedures não alteram dados, apenas retornam conjuntos de resultados.

-- 5.6.1. Busca produtos ativos com estoque > 0
delimiter $$
create procedure busca_produtos_com_estoque_ativos()
begin
    select * from produto
    where ativo = true
      and estoque > 0;
end $$
delimiter ;

-- 5.6.2. Busca produtos ativos sem estoque (estoque = 0)
delimiter $$
create procedure busca_produtos_ativos_sem_estoque()
begin
    select * from produto
    where ativo = true
      and estoque = 0;
end $$
delimiter ;

-- 5.6.3. Busca clientes ativos
delimiter $$
create procedure busca_clientes_ativos()
begin
    select * from cliente
    where ativo = true;
end $$
delimiter ;

-- 5.6.4. Busca usuários ativos
delimiter $$
create procedure busca_usuarios_ativos()
begin
    select * from usuario
    where ativo = true;
end $$
delimiter ;

-- 5.6.5. Busca pedidos por ID de usuário (todas as vendas registradas por determinado operador)
-- Parâmetro: p_usuario_id – ID do usuário a filtrar
delimiter $$
create procedure busca_pedidos_por_usuario(
    p_usuario_id int
)
begin
    select * from pedido
    where usuario_id = p_usuario_id;
end $$
delimiter ;

-- 5.6.6. Busca pedidos por ID de cliente (todas as compras feitas por determinado cliente)
-- Parâmetro: p_cliente_id – ID do cliente a filtrar
delimiter $$
create procedure busca_pedidos_por_cliente(
    p_cliente_id int
)
begin
    select * from pedido
    where cliente_id = p_cliente_id;
end $$
delimiter ;

-- 5.6.7. Busca produtos inativos (para relatórios de catálogo)
delimiter $$
create procedure busca_produtos_inativos()
begin
    select * from produto
    where ativo = false;
end $$
delimiter ;

-- 5.6.8. Busca produtos sem estoque (estoque = 0, independentemente de ativo)
delimiter $$
create procedure busca_produtos_sem_estoque()
begin
    select * from produto
    where estoque = 0;
end $$
delimiter ;


-- ===================================================================
-- 6. Criação de Triggers (Gatilhos de Auditoria e Controle de Estoque)
-- ===================================================================

-- -----------------------------------------------------------
-- 6.1. Trigger: trg_usuario_after_update
-- -----------------------------------------------------------
-- Finalidade: Após atualização de dados na tabela usuario, registrar
--             as alterações na tabela usuario_log.
-- Eventos: AFTER UPDATE em usuario
-- Lógica:
--   - Verifica se algum campo modificável (nome, email, cpf_cnpj, endereco, ativo)
--     foi alterado.
--   - Monta uma string CSV com valores antigos e novos (usando monta_csv).
--   - Insere linha em usuario_log indicando tipo = 'atualizacao_perfil'.
delimiter $$
create trigger trg_usuario_after_update
after update on usuario
for each row
begin
    if old.nome <> new.nome
       or old.email <> new.email
       or old.cpf_cnpj <> new.cpf_cnpj
       or old.endereco <> new.endereco
       or old.ativo <> new.ativo then

        insert into usuario_log (usuario_id, tipo, descricao)
        values (
            new.id,
            'atualizacao_perfil',
            monta_csv_log(
                'id,nome,email,cpf_cnpj,endereco,ativo',
                json_object(
                    'id', old.id,
                    'nome', old.nome,
                    'email', old.email,
                    'cpf_cnpj', old.cpf_cnpj,
                    'endereco', old.endereco,
                    'ativo', old.ativo
                ),
                json_object(
                    'id', new.id,
                    'nome', new.nome,
                    'email', new.email,
                    'cpf_cnpj', new.cpf_cnpj,
                    'endereco', new.endereco,
                    'ativo', new.ativo
                )
            )
        );
    end if;
end $$
delimiter ;


-- -----------------------------------------------------------
-- 6.2. Trigger: trg_produto_after_update
-- -----------------------------------------------------------
-- Finalidade: Após atualização de dados na tabela produto, registrar
--             as alterações na tabela usuario_log (tipo = 'atualizacao_produto').
-- Eventos: AFTER UPDATE em produto
-- Lógica:
--   - Verifica se algum campo modificável (nome, descricao, preco, estoque, ativo)
--     foi alterado.
--   - Monta linha CSV via monta_csv com id, nome, descrição, preço, estoque (antigos e novos).
--   - Insere em usuario_log com tipo = 'atualizacao_produto'.
delimiter $$
create trigger trg_produto_after_update
after update on produto
for each row
begin
    if old.nome <> new.nome
       or old.descricao <> new.descricao
       or old.preco <> new.preco
       or old.ativo <> new.ativo then

        insert into usuario_log (usuario_id, tipo, descricao)
        values (
            /* Não há usuário associado; pode-se usar NULL ou ID de sistema (0) */
            0,
            'atualizacao_produto',
            monta_csv_log(
                'id,nome,descricao,preco,ativo',
                json_object(
                    'id', old.id,
                    'nome', old.nome,
                    'descricao', ifnull(old.descricao, ''),
                    'preco', old.preco,
                    'ativo', old.ativo
                ),
                json_object(
                    'id', new.id,
                    'nome', new.nome,
                    'descricao', ifnull(new.descricao, ''),
                    'preco', new.preco,
                    'ativo', new.ativo
                )
            )
        );
    end if;
end $$
delimiter ;


-- -----------------------------------------------------------
-- 6.3. Trigger: trg_servico_after_update
-- -----------------------------------------------------------
-- Finalidade: Após atualização de dados na tabela servico, registrar
--             as alterações na tabela usuario_log (tipo = 'atualizacao_servico').
-- Eventos: AFTER UPDATE em servico
-- Lógica:
--   - Verifica se campos modificáveis (nome, descricao, preco, ativo) foram alterados.
--   - Monta linha CSV e insere em usuario_log com tipo = 'atualizacao_servico'.
delimiter $$
create trigger trg_servico_after_update
after update on servico
for each row
begin
    if old.nome <> new.nome
       or old.descricao <> new.descricao
       or old.preco <> new.preco
       or old.ativo <> new.ativo then

        insert into usuario_log (usuario_id, tipo, descricao)
        values (
            0,
            'atualizacao_servico',
            monta_csv_log(
                'id,nome,descricao,preco,ativo',
                json_object(
                    'id', old.id,
                    'nome', old.nome,
                    'descricao', ifnull(old.descricao, ''),
                    'preco', old.preco,
                    'ativo', old.ativo
                ),
                json_object(
                    'id', new.id,
                    'nome', new.nome,
                    'descricao', ifnull(new.descricao, ''),
                    'preco', new.preco,
                    'ativo', new.ativo
                )
            )
        );
    end if;
end $$
delimiter ;


-- -----------------------------------------------------------
-- 6.4. Trigger: trg_item_pedido_after_insert
-- -----------------------------------------------------------
-- Finalidade: Após inserção de um item de pedido (produto), atualizar estoque
--             para refletir a saída de mercadoria. Também gera o log de estoque.
-- Eventos: AFTER INSERT em item_pedido
-- Lógica:
--   - Verifica se produto_id do item é não-nulo (diferencia produto de serviço).
--   - Seleciona quantidade atual do produto, subtrai quantidade vendida.
--   - Chama procedure atualiza_estoque que atualiza tabela produto e insere registro
--     em estoque_log.
delimiter $$
create trigger trg_item_pedido_after_insert
after insert on item_pedido
for each row
begin
    declare qtd_atual int;

    if new.produto_id is not null then
        select estoque into qtd_atual from produto where id = new.produto_id;

        -- Atualiza estoque disparando insert em estoque_log
        call atualiza_estoque(new.produto_id, qtd_atual - new.quantidade);
    end if;
end $$
delimiter ;


-- ===================================================================
-- 7. Criação de Views para Relatórios
-- ===================================================================

-- -----------------------------------------------------------
-- 7.1. View: vw_servicos_mais_vendidos
-- -----------------------------------------------------------
-- Finalidade: Retornar os serviços mais vendidos, ordenados pela soma das quantidades
--             vendidas de cada serviço.
-- Campos exibidos:
--   servico_id   : ID do serviço
--   servico_nome : Nome do serviço
--   total_qtd    : Soma das quantidades vendidas (de item_pedido)
create view vw_servicos_mais_vendidos as
select
    s.id as servico_id,
    s.nome as servico_nome,
    sum(ip.quantidade) as total_qtd
from servico s
join item_pedido ip on ip.servico_id = s.id
group by s.id, s.nome
order by total_qtd desc;


-- -----------------------------------------------------------
-- 7.2. View: vw_produtos_mais_vendidos
-- -----------------------------------------------------------
-- Finalidade: Retornar os produtos mais vendidos, ordenados pela soma das quantidades
--             vendidas de cada produto.
-- Campos exibidos:
--   produto_id   : ID do produto
--   produto_nome : Nome do produto
--   total_qtd    : Soma das quantidades vendidas (de item_pedido)
create view vw_produtos_mais_vendidos as
select
    p.id as produto_id,
    p.nome as produto_nome,
    f.nome as fornecedor_nome,
    sum(ip.quantidade) as total_qtd
from produto p
join item_pedido ip on ip.produto_id = p.id
left join fornecedor f on p.fornecedor_id = f.id
group by p.id, p.nome, f.nome
order by total_qtd desc;


-- -----------------------------------------------------------
-- 7.3. View: vw_vendas_por_usuario
-- -----------------------------------------------------------
-- Finalidade: Retornar o total de vendas (soma de total de pedidos) realizadas
--             por cada usuário (operador), mesmo que haja pedidos com usuario_id NULL.
-- Campos exibidos:
--   usuario_id   : ID do usuário (0 se nulo)
--   usuario_nome : Nome do usuário (exibe “Sem Operador” se usuário_id for NULL)
--   total_vendas : Soma do campo total de todos os pedidos daquele usuário
create view vw_vendas_por_usuario as
select
    ifnull(u.id, 0) as usuario_id,
    ifnull(u.nome, 'Sem Operador') as usuario_nome,
    sum(p.total) as total_vendas
from pedido p
left join usuario u on p.usuario_id = u.id
group by ifnull(u.id, 0), ifnull(u.nome, 'Sem Operador')
order by total_vendas desc;



-- -----------------------------------------------------------
-- 7.4. View: vw_clientes_total_gasto
-- -----------------------------------------------------------
-- Finalidade: Retornar o total gasto por cada cliente, considerando apenas
--             clientes ativos (flag ativo = TRUE).
-- Campos exibidos:
--   cliente_id   : ID do cliente
--   cliente_nome : Nome do cliente
--   total_gasto  : Soma dos valores do campo total de todos os pedidos desse cliente
create view vw_clientes_total_gasto as
    SELECT
        c.id as cliente_id,
        c.nome as cliente_nome,
        sum(p.total) as total_gasto
    from
        cliente c
            join
        pedido p on p.cliente_id = c.id
    where
        c.ativo = true
    group by c.id , c.nome
    order by total_gasto desc;


-- ===================================================================
-- 8. Exemplos de Uso para Testes Manuais (Bloqueados por Comentário)
-- ===================================================================

-- Abaixo há um exemplo de como utilizar a procedure realiza_venda com JSON:
-- O JSON monta três itens: dois produtos (IDs 1 e 3) e um serviço (ID 2).
-- A procedure fará a inserção na tabela pedido, inserção em item_pedido,
-- atualização de estoque para produtos e cálculo do total final.

-- set @itens_json = '[
--   {"produto_id": 1, "servico_id": null, "quantidade": 2},
--   {"produto_id": 3, "servico_id": null, "quantidade": 1},
--   {"produto_id": null, "servico_id": 2, "quantidade": 1}
-- ]';

-- call realiza_venda(1, 2, @itens_json);

-- Após a execução:
-- - Um novo registro será criado em pedido, com total = 350000*2 + 7500*1 + 8000*1 = 715000.
-- - Serão inseridos três registros em item_pedido.
-- - A trigger trg_item_pedido_after_insert será disparada para cada item de produto,
--   diminuindo o estoque dos produtos 1 e 3 e gerando registros em estoque_log.
-- - A coluna total da tabela pedido será atualizada para 715000 (R$ 7.150,00).
