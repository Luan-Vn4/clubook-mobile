# MOBILE-25.1-Booklub
<!-- Diff test marker - VS Code edit test -->

---

## 📚 1. Sobre o *Booklub*
*Booklub* é uma plataforma social digital dedicada a conectar leitores apaixonados em clubes de 
leitura. O objetivo é proporcionar um ambiente colaborativo onde membros possam 
discutir livros, definir leituras mensais, agendar encontros e compartilhar seu 
progresso de leitura.

---

## 🏗 2. Arquitetura
### 2.1 *Model, View, View Model* (*MVVM*)
![Diagrama do padrão arquitetural *MVVM*](https://docs.flutter.dev/assets/images/docs/app-architecture/guide/feature-architecture-simplified-with-logic-layer.png)
O projeto busca seguir o padrão arquitetura [MVVM](https://docs.flutter.dev/app-architecture/guide),
pois permite uma melhor separação de responsabilidades entre diferentes camadas
da aplicação, tornando mais clara a organização da lógica de interface de
usuário (*UI*) daquelas ligadas à lógica de negócios e manipulação de dados. 
Essa organização torna a aplicação mais testável e escalável.

Em geral, o padrão *MVVM* pode ser dividido em três camadas que são descritas 
a seguir:
- `UI Layer`: componentes que fazem parte da apresentação ao usuário.
    - Inclui [views](https://docs.flutter.dev/app-architecture/guide#views),
      *widgets* e [view models](https://docs.flutter.dev/app-architecture/guide#view-models);
- `Domain/Logic Layer`: componentes relacionados à regra de negócios e modelos 
   de dados
  - Inclui [use cases](https://docs.flutter.dev/app-architecture/guide#optional-domain-layer)
- `Data Layer`: componentes responsáveis por obter, receber e
  fornecer dados.
    - Inclui [repositories](https://docs.flutter.dev/app-architecture/guide#repositories)
      e [services](https://docs.flutter.dev/app-architecture/guide#services).

### 2.2 Arquitetura Adaptada
Visando manter uma organização flexível que permita desenvolver um 
aplicativo escalável e de fácil manutenção, foram realizadas algumas 
modificações na estrutura do *MVVM*. Apesar disso, todos os componentes que
fazem parte dela ainda estão presentes, mas apenas estão dispostos em camadas
diferentes que visam tornar mais clara a separação da lógica de negócios em
relação à implementação, ou seja, a infraestrutura.

Dessa forma, o projeto segue a seguinte arquitetura:

![Diagrama com estrutura do projeto](https://i.imgur.com/iHU3Ydg.png)

Observe que, como dito anteriormente, os componentes que compõe a arquitetura
*MVVM* ainda estão presentes nesta arquitetura adaptada. A seguir, está um
esquema que destaca através de quadrados tracejados violetas, os componentes
e suas respecitivas camadas no modelo *MVVM* que estão presentes nesta 
arquitetura.

![Diagrama que mostra onde as camadas do *MVVM* se encaixam na arquitetura do projeto](https://i.imgur.com/erSQOtk.png)

### 2.3 Componentes da Arquitetura
A seguir, estão descritos os principais componentes que compõe a arquitetura
proposta para o aplicativo.
- `ui`: Corresponde ao *UI Layer* e contém elementos ligados à visualização e
   interação do usuário.
  - `pages`: são às telas do aplicativo.
  - `widgets`: correspondem aos componentes visuais reutilizáveis que irão 
     compor as *pages* do aplicativo.
    - Incluem: botões, cards, formulários, etc..
  - `layouts`: estruturas fixas que funcionam como uma "moldura" dentro da qual 
     será inserida uma *page*.
    - Incluem: cabeçalhos, rodapés, barras de navegação, etc..
    - Garantem consistência visual e estrutural entre janelas.
  - `view models`: responsáveis por gerenciar o estado das *views* (pages, 
     widgets e layouts) e a lógica da aplicação (como lidar com ações do usuário
     e operações realizadas no aplicativo).
- `domain`: consiste na camada onde estará a lógica e modelos do domínio da
   aplicação, além de interfaces que desacoplam o domínio da camada de 
   infraestrutura onde estão as implementações.
  - `use cases`: também pertence ao *Domain Layer* do *MVVM* e encapsulam
     lógicas de negócio que são muito complexas para *view models*.
    - Na maioria das vezes, a lógica de negócios está nos *view models*,
      portanto esses componentes são opcionais.
    - Caso usado, deve atender a pelo menos uma das condições: 
      ¹Combina dados de múltiplos *repositories*, ²apresenta lógica complexa 
       e/ou ³apresenta uma lógica que será reutilizada por vários *view models*.
  - `repositories`: interface dos *repositories* que serão implementados na
     camada de infraestrutura
  - `gateways`: interface dos *gateways* que serão implementados na camada de
     infraestrutura
  - `models`: representações da entidade no domínio
- `infra`: consiste na camada de infraestrutura onde estão as implementações
   que não estão ligadas propriamente à lógica de negócios.
  - `repositories`: implementações dos *repositories* definidos no *Domain* que
     correspondem aos *repositories* do *Data Layer* da arquitetura *MVVM*
    - Responsáveis por: obter dados, transformar dados brutos em modelos de
      domínio, caching, recarregar dados, etc.
    - Servem como [*Single Source of Truth* (SOTA)](https://docs.flutter.dev/app-architecture/concepts#single-source-of-truth)
    - Deve haver um *repository* para cada entidade no domínio
  - `gateways`: implementações dos *gateways* definidos no *Domain* que são
     responsáveis por realizar chamadas a *API*s
  - `services`: correspondem aos *services* do *Data Layer* da arquitetura 
     *MVVM* e são responsáveis por abstrair lógicas de acesso mais complexas a
     *API*s, bancos de dados, etc.
    - Tanto os *repositories* quanto os *gateways* podem utilizar *services*
      para cumprir suas responsabilidades
    - Isolam o carregamento assíncrono de dados
    - **Não confuda com o conceito de *services* utilizados em *back-end*s de
      aplicações *web***

---

## 📁 3. Organização do Diretório
Conforme a arquitetura proposta para o projeto, a estrutura do diretório do
projeto será dividida em pastas que representam cada uma das camadas.

As pastas principais que estão presentes no diretório `lib` são:
- `ui`: contém arquivos ligados à camada de *ui*, ou seja, contém o código
   ligado à visualização do usuário.
  - A organização dos subdiretórios dessa pasta será feita de maneira semelhante
    ao *Next.js*, ou seja, cada subpasta representará um caminho até aquela
    página.
  - Por exemplo, enquanto o código para a página principal de um clube estaria
    em `ui/clubs`, aquele da página de visualização de membros de um clube 
    estaria em: `ui/club/members`.
- `domain`: contém o código ligado à camada de *domain* que possui a lógica
   de negócios da aplicação, bem como abstrações (interfaces) que são 
   implementadas no `infra`
  - Os subdiretórios de *domain* são dividos de acordo com os diferentes 
    domínios de negócio
  - Por exemplo, os códigos relacionados a usuários estariam em: `domain/users`
- `infra`: corresponde à camada de *infra* e engloba arquivos com código e 
   implementações não estão ligadas propriamente à lógica de negócios.
  - Assim como o `domain`, os subdiretórios dessa pasta são divididos pelo
    domínio que o código estará relacionado ou funcionalidade da infraestrutura
  - Por exemplo, implementações de *repositories* e *gateways* para usuários
    estariam presentes em `infra/users/repositories` e `infra/users/gateways`,
    respectivamente
  - Para o caso de algo que não necessariamente está ligado a um domínio, como
    poderiam ser códigos ligados à busca de imagens em um dispositivo, poderia
    ter algo como: `infra/media_picker`
- `config`: contém arquivos de configuração do aplicativo
- `utils`: contém utilitários que podem ser usados em diferentes partes da
   aplicação

```
📁lib
├───📁config -> Arquivos de Configuração
│     ├─📁routing -> Arquivos para gerenciamento de rotas do aplicativo
│     │   ├─🔷router_config.dart -> Lógica de roteamento
│     │   └─🔷routes.dart -> Listagem das rotas disponíveis
│     ├─🔷<config_name>_config.dart
│     └─🔷theme_config.dart
├───📁ui -> Arquivos ligados à interface de usuário (view)
│   ├───📁core -> Arquivos que sejam comuns a diferentes páginas
│   │   └───📁widgets -> Widgets compartilhados entre várias páginas
│   ├──📁home
│   │   ├───🔷home_page.dart
│   │   ├───📁view_models
│   │   └───📁widgets
│   └───📁<page_name>
│       ├───📁<related_page_name> -> Páginas podem ter subpáginas relacionadas
│       │       ├───🔷<related_feature_name>_page.dart
│       │       ├───📁view_models
│       │       └───📁widgets
│       ├───🔷<feature_name>_page.dart -> Página principal da feature
│       ├───📁view_models -> Arquivos de View Model daquela página
│       └───📁widgets -> Widgets utilizados apenas naquela página
├───📁domain -> Arquivos ligados à lógica de negócios e interfaces de repositories e gateways
│   └─📁<domain_name>
│       ├───📁models -> Representações da entidade no domínio
│       │       └───🔷<data_model_name>.dart
│       ├───📁repositories -> Interfaces dos repositories
│       ├───📁gateways -> Interfaces dos gateways
│       └───📁use_cases -> Componentes para abstrair lógicas de negócio muito complexas para view models (opcional)
├───📁infra -> Arquivos de implementação de infraestrutura
│   └───📁<domain_name>
│       ├───📁repositories -> Implementações dos repositories
│       ├───📁gateways -> Implementações dos gateways
│       └───📁services -> Services para abstrair lógicas de acesso mais complexas
└───📁utils -> Arquivos de utilitários
```

Na raiz do projeto, há outra pasta `test` que seguirá a mesma
estrutura da pasta `lib`.
```
📁test
├───📁config
├───📁ui
├───📁domain
└───📁utils
```