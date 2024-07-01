## Personalizando Acessos e Automatizando Ações no MySQL

Para garantir a segurança e a eficiência do banco de dados, é importante configurar permissões de acesso adequadas e automatizar algumas ações administrativas. A seguir, vamos detalhar como personalizar acessos de usuários e como criar triggers para automatizar certas operações no MySQL.

### Personalizando Acessos de Usuários

#### Criação de Usuários e Concessão de Permissões

1. **Criação de Usuários**

    ```sql
    -- Cria um usuário para operações administrativas
    CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'admin_password';

    -- Cria um usuário para operações de leitura
    CREATE USER 'read_user'@'localhost' IDENTIFIED BY 'read_password';

    -- Cria um usuário para operações de escrita
    CREATE USER 'write_user'@'localhost' IDENTIFIED BY 'write_password';
    ```

2. **Concessão de Permissões**

    ```sql
    -- Concede permissões completas ao usuário administrativo
    GRANT ALL PRIVILEGES ON *.* TO 'admin_user'@'localhost' WITH GRANT OPTION;

    -- Concede permissões de leitura ao usuário de leitura
    GRANT SELECT ON database_name.* TO 'read_user'@'localhost';

    -- Concede permissões de leitura e escrita ao usuário de escrita
    GRANT SELECT, INSERT, UPDATE, DELETE ON database_name.* TO 'write_user'@'localhost';

    -- Aplica as alterações de permissões
    FLUSH PRIVILEGES;
    ```

### Automatizando Ações com Triggers

Triggers são usados para executar automaticamente um bloco de código SQL em resposta a certos eventos no banco de dados, como `INSERT`, `UPDATE` ou `DELETE`.

#### Exemplos de Triggers

1. **Trigger para Atualizar o Campo `data_atualizacao` na Tabela `Pedidos`**

    ```sql
    DELIMITER //

    CREATE TRIGGER before_pedidos_update
    BEFORE UPDATE ON Pedidos
    FOR EACH ROW
    BEGIN
        SET NEW.data_atualizacao = NOW();
    END //

    DELIMITER ;
    ```

    Neste exemplo, toda vez que um registro na tabela `Pedidos` for atualizado, o campo `data_atualizacao` será automaticamente definido para a data e hora atuais.

2. **Trigger para Logar Operações de `DELETE` na Tabela `Clientes`**

    ```sql
    DELIMITER //

    CREATE TRIGGER after_clientes_delete
    AFTER DELETE ON Clientes
    FOR EACH ROW
    BEGIN
        INSERT INTO Log_Clientes_Excluidos (id_cliente, nome, endereco, tipo_cliente, data_exclusao)
        VALUES (OLD.id_cliente, OLD.nome, OLD.endereco, OLD.tipo_cliente, NOW());
    END //

    DELIMITER ;
    ```

    Neste exemplo, toda vez que um registro na tabela `Clientes` for excluído, os detalhes do registro excluído serão inseridos na tabela `Log_Clientes_Excluidos`.

3. **Trigger para Validar CPF ao Inserir ou Atualizar Cliente PF**

    ```sql
    DELIMITER //

    CREATE TRIGGER before_clientes_pf_insert
    BEFORE INSERT ON Clientes_PF
    FOR EACH ROW
    BEGIN
        DECLARE invalid_cpf EXCEPTION;
        IF LENGTH(NEW.cpf) <> 11 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CPF inválido';
        END IF;
    END //

    CREATE TRIGGER before_clientes_pf_update
    BEFORE UPDATE ON Clientes_PF
    FOR EACH ROW
    BEGIN
        IF LENGTH(NEW.cpf) <> 11 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'CPF inválido';
        END IF;
    END //

    DELIMITER ;
    ```

    Esses triggers verificam se o CPF tem 11 dígitos antes de inserir ou atualizar um registro na tabela `Clientes_PF`. Se o CPF for inválido, um erro será sinalizado.

### Considerações Finais

Com a configuração de permissões de usuários e a automação de ações usando triggers, o banco de dados torna-se mais seguro, eficiente e fácil de manter. As permissões garantem que os usuários tenham apenas o acesso necessário para suas funções, enquanto os triggers automatizam tarefas repetitivas e asseguram a integridade dos dados.
