# Sistema de Clima Organizacional - Guia Operacional

## Objetivo

Este sistema permite gerir estudos de clima organizacional para várias empresas cliente, usando um único ficheiro HTML autónomo.

O sistema cobre:

- criação e configuração de empresas cliente;
- questionário de clima com 12 dimensões e 48 perguntas;
- recolha direta de respostas em ambiente controlado;
- importação de respostas exportadas de Microsoft Forms ou Google Forms;
- dashboard automático;
- relatório pronto a imprimir/guardar em PDF;
- plano de ações de curto, médio e longo prazo.

## Forma recomendada de utilização com clientes

## Opção recomendada com backend Supabase

Esta passa a ser a forma recomendada quando o objetivo é escalar o serviço com vários clientes e recolha remota real.

1. Criar um projeto em Supabase.
2. Abrir o ficheiro `supabase_schema_clima.sql`.
3. Copiar todo o conteúdo para o SQL Editor do Supabase e executar.
4. Criar um utilizador da consultora em `Authentication > Users`.
5. Abrir `Sistema_Clima_Organizacional.html`.
6. No bloco `Supabase`, ativar `Usar Supabase`.
7. Introduzir `Project URL` e `anon public key` do projeto Supabase.
8. Fazer login com o utilizador criado.
9. Criar/configurar a empresa cliente.
10. Clicar em `Sincronizar`.
11. Copiar o link de resposta gerado.
12. Enviar o link ao cliente/trabalhadores.
13. As respostas ficam guardadas centralmente no Supabase.
14. No painel, clicar novamente em `Sincronizar` para atualizar empresas/respostas.
15. Abrir `Análise` e `Relatório`, e guardar em PDF.

Nota: a `anon public key` do Supabase pode estar no frontend. A segurança depende das políticas RLS incluídas no ficheiro SQL. Não usar service role key no HTML.

### Opção A - Mais simples e segura para escala

1. Criar um Microsoft Forms ou Google Forms por cliente.
2. Copiar as perguntas do separador `Questionário` do HTML.
3. Desativar recolha automática de email.
4. Não pedir nome, telefone, número interno, email ou qualquer identificador pessoal.
5. Recolher respostas durante 7 a 10 dias.
6. Exportar respostas para CSV.
7. Abrir `Sistema_Clima_Organizacional.html`.
8. Criar/selecionar a empresa cliente.
9. Importar o CSV no separador `Respostas`.
10. Abrir `Análise` e `Relatório`.
11. Imprimir ou guardar o relatório como PDF.

Esta opção é a melhor para clientes externos porque evita depender do armazenamento local do navegador dos respondentes.

### Opção B - Recolha direta no HTML

Usar apenas quando todas as respostas são recolhidas no mesmo computador/dispositivo ou num ambiente controlado pela consultora.

1. Criar empresa cliente.
2. Copiar o link do questionário.
3. Abrir o link no mesmo navegador.
4. As respostas ficam guardadas localmente.

## Regras de segurança e anonimato

- Não recolher identificadores diretos.
- Não publicar cortes por segmento com menos de 5 respostas.
- Guardar uma base JSON por cliente/projeto.
- Manter os ficheiros numa pasta de cliente com permissões restritas.
- Definir no contrato o período de retenção dos dados.
- Comunicar aos trabalhadores a finalidade do estudo, voluntariedade, anonimato e uso agregado dos resultados.

## Fontes de boas práticas consideradas

- Pew Research Center: boas práticas de desenho de perguntas, clareza, pré-teste e ordem do questionário.
- GOV.UK Service Manual: consentimento informado, minimização, retenção e gestão de dados de investigação.
- NIST Privacy Framework: gestão de risco de privacidade.
- Online Surveys: anonimato depende do desenho do questionário e da não recolha de dados identificativos.

## Limitação técnica importante

O HTML é autónomo e não tem servidor/base de dados central. Por isso, para recolha remota em massa, a melhor arquitetura é:

`Forms anónimo -> exportação CSV -> importação automática no HTML -> relatório PDF`

Para uma versão totalmente automática na web, o próximo passo será ligar este frontend a uma base de dados com autenticação, permissões por cliente, consentimento e exportação automática de relatórios.

Esse próximo passo ficou preparado através do ficheiro `supabase_schema_clima.sql` e da integração Supabase no HTML.
