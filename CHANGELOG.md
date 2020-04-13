# Changelog

Todas as alterações neste projeto serão documentadas neste arquivo.

Este formato é baseado em [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), e o controle e versão deste projeto segue o [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2020-04-11

### Added

- Adicionado o diretório tools/ cujo objetivo é fornecer ferramentas úteis, incluindo scripts que auxiliam o controle de versão deste repositório
- Adicionado ao changelog, uma versão resumida das versões passadas, com o intuito de manter o histórico desde a primeira versão
- Adicionado informações de contribuição na documentação

### Changed

- Incluido um controle de versão via CHANGELOG seguindo os o semantic versioning e o keep a changelog.

### Fixed

- Ajuste na procedure dbo.stpAlert_Every_Day que não é mais necessária. Apenas mantendo ela pra compatibilidade anterior.

## [2.0.0] - 2017-09-22

### Added

- Inclusão de novos alertas, totalizando 40
- Envio do projeto para o github
- Melhorias e reorganização da documentação
- Inclusão de suporte ao Inglês
- Adicionado README em inglês. Obrigado @edvaldocastro

### Changed

- Alterado link de donwload da whoisactive para apontamento pro git. Orbigado @joaoavilars

## [1.1.0] - 2017-10-05

### Added

- Inclusão de novos alertas, totalizando 15
- Criação da procedure sp_Whoisactive

## [1.0.0] - 2017-05-01

### Added

- Criação da base Traces, jobs e configuração de email, e inclusão de um trace para capturar queries lentas

### Changed

- Removido a planilha excel, e agora os scripts enviam por emails

## [0.0.1] - 2010-03-24

### Added

- Planilha excel para gerar 6 abas contendo checklist essencial do SQL Server



[2.1.0]: https://github.com/soupowertuning/Script_SQLServer_Alerts/compare/v2.0.0...v2.1.0
[2.0.0]: https://www.fabriciolima.net/blog/2019/09/22/passo-a-passo-de-como-criar-40-alertas-para-monitorar-seu-sql-server/
[1.1.0]: https://www.fabriciolima.net/blog/2017/10/05/video-criando-15-alertas-no-sql-server-em-apenas-5-minutos/
[1.0.0]: https://www.fabriciolima.net/blog/2017/05/01/criando-um-e-mail-de-checklist-diario-no-sql-server/
[0.0.1]: https://www.fabriciolima.net/blog/2010/03/24/criando-um-checklist-automatico-do-banco-de-dados/
