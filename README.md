> [!CAUTION]
> Estes scripts não são mais atualizados e podem conter bugs. Não recomendamos o uso em produção.  
> Para produção, recomendamos usar o [Power Alerts](https://poweralerts.com.br/), que contém atualizações e correcoes de bugs.

# Scripts para criar 40 Alertas no SQL Server

**For english, [click here](README.en.md)**


*** Atualização 21/03/2023 - Aproveite e conheça o Power Alerts, uma evolução GIGANTE desse script de alertas da comunidade: https://powertuning.com.br/poweralerts/


Fala Pessoal,

Nesse repositório quero compartilhar com vocês um projeto que surgiu em 2010 com um e-mail para criar um checklist de um banco de dados 
e enviar via excel por email:

<https://www.fabriciolima.net/blog/2010/03/24/criando-um-checklist-automatico-do-banco-de-dados/>

Com o passar dos anos fui evoluindo esses scripts e utilizando nos bancos de dados que administramos.

Em 2017 divulguei uma nova versão dese checklist agora em um e-mail com HTML que foi um sucesso:

<https://www.fabriciolima.net/blog/2017/05/01/criando-um-e-mail-de-checklist-diario-no-sql-server/>

Também divulguei uma versão com 15 alertas para serem criados no SQL Server:
<https://www.fabriciolima.net/blog/2017/10/05/video-criando-15-alertas-no-sql-server-em-apenas-5-minutos/>

Até o dia 18/09, foram 2.6k views para o vídeo do checklist e 2.1k views para o vídeo dos alertas.

Com o passar do tempo, continuamos evoluindo os scripts que utilizamos no dia a dia, e agora em 2019 liberei essa nova versão, que já cobre 40 alertas, incluindo o e-mail de checklist e um e-mail mensal com informações da sua instância.


Esse não é um projeto do Fabrício, e sim de vocês. Por este motivo, estou liberando todo o código no Github, para que todos vocês possam baixar, utilizar em seus ambientes e ajudar a deixá-la cada vez melhor através de contribuições via issues, pull requests, etc..  
Assim sempre manteremos tudo isso atualizado com novos recursos e correções.

Gostaria de agradecer a todo o #TeamPowerTuning (na época ainda sob o nome #TeamFabricioLima) que contribuiram demais para esses scripts com ideias e códigos. 

Sem eles, esses scripts não estariam dessa forma hoje. Eu demoraria muito mais para produzir.

Segue o Artigo desses scripts caso precisem de ajuda para executá-los: 

<http://www.fabriciolima.net/blog/2019/09/22/passo-a-passo-de-como-criar-40-alertas-para-monitorar-seu-sql-server/>

## Como instalar os alertas?

* [Faça o donwload da última release](https://github.com/soupowertuning/Script_SQLServer_Alerts/releases/latest)
  * **Dica**: Você pode usar alguma ferramenta (como o git) para fazer o clone, ou baixar manualmente este repositório.
* Todos os scritps estão no diretório [scripts](scripts/)
* Para iniciar, siga as instruções do arquivo [scripts/1.0.StepByStep.sql](scripts/1.0.StepByStep.sql)


## Como contribuir?

Você pode contribuir para a melhoria deste projeto! [Leia nosso guia de contribuição](doc/CONTRIB.md)


Fabrício Lima  
_CEO Power Tuning_
