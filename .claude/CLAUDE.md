# Projeto

Tatical RPG estilo xcom desenvolvido em GODOT 4.7
Godot exectutable is located in C:\godot\engine\Godot_v4.7.1-stable_win64.exe

---

## Perfil do Desenvolvedor & Contexto
* **Experiência:** Desenvolvedor de Software Sênior (20+ anos de experiência). Forte conhecimento em arquitetura de software e design patterns.
* **Histórico relevante:** Experiência anterior com Adobe Flash (DisplayList, Event-Driven Architecture, ActionScript 3).
* **Domínio de Engine:** Iniciante no Godot.
* **Preferência Arquitetural:** 
  * **Alta abstração lógica:** Prefira código/arquitetura orientada a objetos decoupling e padrões estabelecidos (MVC, MVP, Dependency Injection, State Pattern) em vez de acoplar lógica de negócio diretamente nos nós da engine (`Node` / `Node2D` / `Control`).
  * Não force lógica de domínio a depender de nós/Cena se puder ser tratada por classes GDScript puras (`RefCounted` / `Object`).

---

## Arquitetura & Padrões de Código

### 1. Separação de Responsabilidades (Domain vs. Engine)
* **Modelos / Lógica de Domínio:** Devem herdar de `RefCounted` (para gerenciamento de memória automático) ou `Resource`, sem dependências de visualização ou ciclo de vida de física (`_process`, `_physics_process`).
* **Visualização / Renderização (Nós do Godot):** Use `Node`, `Node2D`, `Control`, etc., puramente como "Views" burras ou controladores de apresentação.
* **Comunicação:** Utilize sinais (`signals`) do GDScript como um barramento de eventos (event bus) desacoplado, similar ao modelo de eventos do ActionScript 3 / Flash. Evite usar `get_node()` ou caminhos relativos rígidos (`$"../SomeNode"`).

### 2. Estilo de Código & Tipagem
* **Strict Typing:** Use tipagem estática no GDScript para garantir type-safety (`var hp: int = 100`, `func take_damage(amount: int) -> void:`).
* **Classes Claras:** Use a palavra-chave `class_name` em todas as classes reutilizáveis para garantir escopo global e autocompletion estático.
* **Injeção de Dependências:** Prefira passar dependências explicitamente via construtor (`_init()`) ou métodos de inicialização em vez de resolver dependências buscando na árvore de cena (`get_parent()`, `get_node()`).

---

## Estrutura do Projeto & Convenções
* `scripts/mechanics/`: Mecanicas padrões de personagem, gatilhos de cenário, batalhas e afins.
* `scripts/services/` Pré carregamento e serviços externos incluindo websockets e similares
* `scenes/`: Cenas Godot (.tscn) contendo os nós visuais/físicos que apenas reagem a mudanças de estado da camada de domínio.
* `resources/`: Media e similares

---

## Tom e Formato de Resposta das IAs
* **Comunicação:** Respostas diretas, técnicas e sem explicações básicas de conceitos gerais de programação (ex: não explique o que é um Singleton ou Polimorfismo).
* **Código:** Apresentar código bem estruturado, totalmente tipado e focado em manter o código desacoplado da engine sem quebrar as boas práticas internas do Godot.
* **Comentários:** Comente aquilo que pode ser desafiador para quem não tem afinidade com Game Engines ou não tem afinidade com GD Script e precisa entender as nuances do código/arquitetura 