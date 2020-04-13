# Como contruibuir?

Você pode contribuir com este projeto de diversas formas: melhorando documentação, corrigindo bugs, adicionando novas funcionalidades, etc.  
Alguns usuários podem querer apenas reportar e descrever suas contribuições. Para isso, eles podem abrir **Issues**.  
Já para outros, além de descrever, eles já virão com os arquivos alterados. Para isso, existe o **Pull Request**.

O fluxo básico é: Vocês submetem a correção e a equipe da Power Tuning revisa. Este processo pode levar algum tempo.
Suas contribuições podem não entrar individualmente. Isto é, nós podemos juntar diversas contribuições em uma única versão e publicá-las!
O jeito é ter um pouco de paciência mesmo. Tudo isso é por uma questão de qualidade.  

Sempre fique atento às regras gerais de contribuição!

## Regras gerais de contribuição

- Forneça o máximo de documentação no código e na descrição das sua submissões, seja ela um Issue ou Pull Request.
- **Revise seu código e garanta que não há dados privados como emails, usuários e até senhas**
- Separe dados de código. Dados de testes devem vir separados do código, isto é, da lógica principal! Parametrize o máximo que puder!

## Fluxo Geral de Contribuição

- Você submete sua contribuição
- Alguém da Power Tuning revisa, testa, etc.
- Se houver problemas ou precisarmos de mais informações, entramos em contato através do git. Por isso, fique de olho no email cadastrado do git.
- Se a submissão for aprovada, nós iremos fazer testes e mais testes. Este pode ser um período longo.
- Estando tudo ok, marcamos ele para entrar na próxima versão
- Iremos incluir suas alterações em nosso CHANGELOG e você também constará como um contribuitor do repositório de Scripts e Alertas da Power Tuning!

## Diretório tools

O diretório tools foi criado com intuito de prover uma série de ferramentas, incluindo ferramentas que auxiliam o controle de versão deste repositório.  
O script `PrepareNextVersion.ps1` é um powershell utilizado para validar se o COMMIT atual está nos coformes para a próxima versão!

### Versionamento

O versionamento do projeto segue o Semantic Versioning. Nós utilizamos o arquivo `info.params.ps1` para organizar os commits e controlar os números de versão.  
Também, para cada nova versão, nós utilizamos uma tag no git, no formato `v + VERSAO`, onde `VERSAO` é número de versão no formato `X.Y.Z`.  

Somente alguns usuário estarão autorizados a gerar uma nova versão. Mas você pode usar o procedimento descrito aqui para aprender e quem sabe um dia, nos ajudar com isso!  

Procedimento:

* Atualizar o branch release com a cópia do branch master
* Alterar o arquivo `info.params.ps1` e adicionar um novo elemento na tabela de versão. O arquivo contém as explicações.
* Alterar os arquivos .sql que contém informações de versão.
* Execute o arquivo `tools\PrepareNextVersion.ps1`. Ele irá fazer uma série de valiações, gerar um novo CHANGELOG e criar os commits no git!

