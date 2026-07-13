# Remote Flutter Widgets (RFW) — exemplo educativo

Demo mínima do pacote oficial [`rfw`](https://pub.dev/packages/rfw) (Flutter / flutter.dev).

A tela do contador **não** é escrita em Dart: vem de um arquivo declarativo `.rfwtxt` carregado em runtime.

---

## O que é RFW?

**Remote Flutter Widgets** é um pacote que renderiza árvores de widgets a partir de **descrições declarativas obtidas em runtime** (rede, cache, asset…), em vez de só a partir de código Dart compilado no app.

Em termos práticos:

- O **app** já contém widgets Flutter “de verdade” (`Text`, `Scaffold`, `ElevatedButton`…) — as **libs locais**.
- O **remoto** manda um arquivo dizendo *como* montar esses widgets — a **lib remota** (`.rfw` / `.rfwtxt`).
- Separadamente, manda (ou o app atualiza) **dados** — o `DynamicContent` (`data.user.name`, etc.).
- Toques e callbacks no remoto viram **eventos** tratados em Dart (`onEvent`).

Não é um motor de UI paralelo: RFW **compõe** widgets Flutter já existentes. Não inventa gestos, painters ou transições novas.

> Status: pacote relativamente estável; formato e set de widgets tendem a ser compatíveis para trás (best-effort). Ver [pub.dev/packages/rfw](https://pub.dev/packages/rfw).

---

## Como funciona (conceito)

```text
  Servidor / asset                App Flutter (compilado)
  ─────────────────               ───────────────────────
  lib remota (.rfw)      ──►      Runtime
  dados (JSON-like)      ──►      DynamicContent
                                  + libs locais (core/material)
                                         │
                                         ▼
                                   RemoteWidget
                                         │
                              eventos ◄──┘──► lógica Dart
                                         │
                                         ▼
                              data.update → UI redesenha
```

| Nome | Papel |
|------|--------|
| **Lib remota** | Descrição da UI (layout, textos, botões…) |
| **Lib local** | Implementação Flutter real de cada widget nomeado |
| **DynamicContent** | Dados vivos que o remoto lê via `data.*` |
| **Runtime** | Junta libs locais + remota |
| **RemoteWidget** | Widget Flutter que pinta o resultado |
| **Evento** | `event "nome" {}` no remoto → callback no app |

A lib remota **sempre** termina em widgets locais. Sem lib local correspondente, o nome remoto não renderiza.

---

## Quando usar

RFW brilha quando a UI é **montagem de componentes já prontos** e o conjunto de telas/layouts **não cabia no release do app**.

| Caso | Por quê RFW ajuda |
|------|-------------------|
| Message of the day / anúncios | UI muda no servidor sem store review |
| Cards de busca ricos | Cada tipo de resultado pode ter layout próprio |
| Editores de dados / formulários | Schema do backend → formulário sob medida |
| Experimentos de UI / A-B de layout | Troca a lib remota, não o binário do app |
| Conteúdo editorial (promo, onboarding leve) | Designers/backend iteram no `.rfw` |

**Regra de ouro (do README oficial):** bom para UIs feitas de **peças pré-construídas**; ruim para inventar comportamento visual novo.

---

## Quando *não* usar

| Caso | Por quê evitar |
|------|----------------|
| App inteiro “só RFW” | Não substitui Flutter; tenta e quebra |
| Navegação / page transitions | Fluxo de app = Flutter nativo |
| Drag-and-drop, painters, animações custom | RFW não cria esses widgets |
| Redesign global / nova feature core | Melhor shipar app novo pelas stores |
| Lógica de negócio complexa no remoto | Remoto descreve UI; lógica fica no Dart (ou Wasm à parte) |

---

## Prós e contras

### Prós

- **UI sem novo release de loja** — baixa `.rfw`, cacheia, renderiza.
- **Separação UI × dados** — layout e `DynamicContent` atualizam independente.
- **Widgets reais Flutter** — Material/Cupertino/core já existentes (e libs locais suas).
- **Formato estável (meta)** — arquivos antigos tendem a continuar válidos.
- **Server-side friendly** — `formats.dart` parseia/encoda sem `dart:ui` (gera blob no backend).
- **Eventos explícitos** — remoto não executa Dart arbitrário; só declara `event`.

### Contras / limitações

- **Não cria widgets novos** — só reutiliza o que o app já registrou.
- **Set de widgets limitado** — subset de `widgets` / `material` / `cupertino` (+ os que você expor).
- **Texto `.rfwtxt` é lento** — em produção use blob `.rfw` (`decodeLibraryBlob`).
- **Tipagem rígida nos dados** — distingue `int`/`double`, sem `null`; `Text` exige pedaços String.
- **Tentação de “remote-everything”** — oficialmente desencorajado.
- **Performance teórica** — há limites conhecidos na implementação; em geral ok, mas não é magia.
- **DX** — editar asset exige hot **restart**; tooling/IDE pior que Dart.

---

## RFW vs alternativas (visão rápida)

| Abordagem | Ideia | Diferença vs RFW |
|-----------|--------|------------------|
| **Flutter “normal”** | UI no código do app | Precisa de release para mudar layout |
| **WebView** | HTML/JS remoto | Outro runtime; menos nativo |
| **JSON → widgets caseiros** | Seu parser + switch | RFW já tem formato, Runtime, libs oficiais |
| **Server-driven UI genérico** | Vários SDKs | RFW é específico Flutter + widgets reais |

RFW = server-driven UI **com** o engine Flutter que você já tem, não um browser embutido.

---

## Ideia em uma frase (deste exemplo)

O app sabe desenhar botões e textos.  
O arquivo remoto diz *quais* e *como*.  
O Dart trata os cliques e atualiza os dados.

---

## As 4 peças neste repo

```text
┌─────────────────┐     ┌──────────────────┐
│  Lib remota     │     │  DynamicContent  │
│  (.rfwtxt/.rfw) │     │  data.user…      │
└────────┬────────┘     └────────┬─────────┘
         │                       │
         ▼                       ▼
              ┌──────────┐
              │ Runtime  │  ← libs locais (core/material)
              └────┬─────┘
                   ▼
            ┌─────────────┐
            │ RemoteWidget│ ──onEvent──► lógica Dart
            └─────────────┘
```

| Peça | Neste repo |
|------|------------|
| Lib remota | `assets/remote/counter.rfwtxt` |
| Libs locais | `createCoreWidgets()` + `createMaterialWidgets()` |
| DynamicContent | `user`, `counter` |
| Eventos | `increment` / `reset` → `onEvent` |

---

## Arquivo que importa: `counter.rfwtxt`

Abra e leia — é o coração do exemplo.

```rfwtxt
import core.widgets;
import core.material;

widget root = Scaffold(
  …
  Text(text: ["Olá, ", data.user.name, "!"]),
  ElevatedButton(
    onPressed: event "increment" {},
    …
  ),
);
```

| Sintaxe | Significado |
|---------|-------------|
| `import core.widgets` | Lib local `LibraryName(['core','widgets'])` |
| `widget root = …` | Entrypoint (`FullyQualifiedWidgetName(main, 'root')`) |
| `data.user.name` | Nó do `DynamicContent` |
| `event "increment" {}` | `onEvent('increment', …)` no Dart |
| `text: ["a", data.x, "b"]` | Concatena pedaços num `Text` |

---

## Fluxo runtime (Dart)

```dart
runtime.update(coreName, createCoreWidgets());
runtime.update(materialName, createMaterialWidgets());
runtime.update(mainName, parseLibraryFile(rfwtxt));

data.update('user', {'name': 'Gabriel'});
data.update('counter', {'value': '0'});  // String!

RemoteWidget(
  runtime: runtime,
  data: data,
  widget: FullyQualifiedWidgetName(mainName, 'root'),
  onEvent: onEvent,
);
```

Evento `increment` → lógica Dart → `data.update` → UI remota redesenha.

---

## Texto vs binário

| Formato | API | Quando |
|---------|-----|--------|
| `.rfwtxt` | `parseLibraryFile` (`package:rfw/formats.dart`) | Aprender / editar à mão |
| `.rfw` | `encodeLibraryBlob` / `decodeLibraryBlob` | Produção (~10× mais rápido) |

`package:rfw/rfw.dart` esconde os parsers de texto no cliente de propósito — blob no app.

---

## Tipagem no `Text`

O `Text` local do RFW lê cada pedaço como **String**.  
`data.counter.value` como `int` `0` → número some.

Neste exemplo: sempre `'0'`, `'1'`, …

---

## Como rodar e ver mudanças

```bash
flutter pub get
flutter run
```

1. Edite `assets/remote/counter.rfwtxt`
2. Pressione **`R`** (hot **restart**)
3. Hot reload (`r`) **não** atualiza assets

Experimentos: título do `AppBar`, `OutlinedButton`, novo `event "hello" {}` + `case` em `onEvent`.

---

## Mapa dos arquivos (RFW)

| Arquivo | Papel |
|---------|--------|
| `assets/remote/counter.rfwtxt` | Lib remota (DSL) |
| `…/remote_counter_view_model.dart` | `Runtime`, `DynamicContent`, parse, `onEvent` |
| `…/remote_counter_view.dart` | `RemoteWidget` |
| `…/remote_ui_repository.dart` | Source + mapa inicial do `data` |
| `…/remote_ui_service.dart` | Origem da lib (asset; troque por HTTP) |

---

## Teste

```bash
flutter test
```

Parse da lib, dados iniciais e evento `increment`.

---

## Referências

- [rfw — pub.dev](https://pub.dev/packages/rfw) (definição oficial, limitações, exemplos)
- [Runtime](https://pub.dev/documentation/rfw/latest/rfw/Runtime-class.html)
- [DynamicContent](https://pub.dev/documentation/rfw/latest/rfw/DynamicContent-class.html)
- [RemoteWidget](https://pub.dev/documentation/rfw/latest/rfw/RemoteWidget-class.html)
- Exemplos no pacote: `example/hello`, `example/remote`
