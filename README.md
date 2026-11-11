# 📚 Estante de Leitura (Alexandria)

Aplicativo mobile desenvolvido em **Flutter** e **Dart** com suporte ao **Firebase** para gerenciamento de estante pessoal de livros. O projeto permite organizar leituras nas categorias "Quero ler", "Lendo" e "Lido", acompanhar a porcentagem de progresso de leitura, avaliar livros concluídos com nota de 1 a 5 estrelas e visualizar a quantidade de livros lidos no ano atual.

---

## 🌟 Funcionalidades Principais

- 🔐 **Autenticação de Usuários:** Cadastro, login e logout com e-mail e senha utilizando o **Firebase Authentication**.
- 🛡️ **Proteção de Telas:** Rota raiz monitorada via `AuthGate`, impedindo acesso à estante sem autenticação.
- 📖 **Organização por Abas:** Separação dinâmica dos livros em três abas com contadores em tempo real:
  - **Quero ler:** Cadastro de novos livros e total de páginas.
  - **Lendo:** Acompanhamento de página atual com barra de progresso em porcentagem (%).
  - **Lidos:** Avaliação de 1 a 5 estrelas (`RatingStars`) e data de conclusão da leitura.
- 🏆 **Meta de Leitura Anual:** Card de destaque no topo da tela inicial contabilizando as leituras concluídas no ano vigente.
- ✏️ **CRUD Completo de Livros:** Adicionar, editar, visualizar e excluir livros.
- 🗑️ **Exclusão Rápida:** Suporte a gesto de deslizar para a esquerda (*swipe*) com confirmação modal.
- 🎨 **Interface Moderna:** Construída em **Material 3** com suporte a modo claro e escuro.

---

## 🛠️ Tecnologias Utilizadas

- **Framework:** [Flutter](https://flutter.dev/) (Material 3)
- **Linguagem:** [Dart](https://dart.dev/) (Null Safety)
- **Backend & Autenticação:**
  - `firebase_core`: Inicialização do ecossistema Firebase.
  - `firebase_auth`: Gerenciamento de sessões e usuários.
  - `cloud_firestore`: Banco de dados NoSQL em tempo real.
- **Utilitários:**
  - `intl`: Formatação de datas em português do Brasil (`dd/MM/yyyy`).

> 📌 **Gerenciamento de Estado:** Nativo com `StatefulWidget`, `StreamBuilder` e `FutureBuilder`.

---

## 📁 Estrutura de Pastas

```text
lib/
├── main.dart                    # Inicialização do Firebase, tema Material 3 e navegação
├── routes.dart                  # Constantes e gerador de rotas nomeadas
├── firebase_options.dart        # Configurações do Firebase (gerado via CLI)
├── models/
│   └── book.dart                # Modelo Book e enum BookStatus (fromFirestore, toMap, copyWith)
├── services/
│   ├── auth_service.dart        # Serviço de autenticação e mapeamento de erros AuthException
│   └── database_service.dart    # Serviço CRUD do Firestore (users/{uid}/books)
├── screens/
│   ├── auth_gate.dart           # Rota raiz (StreamBuilder do authStateChanges)
│   ├── login_screen.dart        # Tela de login com validação e feedback em SnackBar
│   ├── register_screen.dart     # Tela de cadastro com updateDisplayName
│   ├── home_screen.dart         # Tela principal com abas, meta do ano e lista de livros
│   └── book_form_screen.dart    # Formulário unificado de criação e edição
├── utils/
│   └── validators.dart          # Utilitários estáticos para validação de formulários
└── widgets/
    ├── book_card.dart           # Card responsivo com progresso e detalhes do livro
    ├── rating_stars.dart        # Seletor/exibidor interativo de 5 estrelas
    ├── yearly_counter_card.dart # Card com estatísticas de leitura do ano atual
    └── empty_state.dart         # Widget para listas e abas vazias
```

---

## 🔐 Autenticação (Firebase Auth)

- A classe `AuthService` encapsula as chamadas ao `FirebaseAuth`.
- O `AuthGate` atua no topo da árvore de widgets escutando a `Stream<User?> authStateChanges`. Enquanto a verificação é realizada, um indicador de carregamento é exibido. Caso o usuário esteja autenticado, a `HomeScreen` é carregada; caso contrário, a `LoginScreen` é exibida.
- **Tratamento de Erros:** Exceções do tipo `FirebaseAuthException` são capturadas e convertidas na classe customizada `AuthException` com mensagens amigáveis em português:
  - `invalid-email` → *"E-mail inválido."*
  - `user-disabled` → *"Esta conta foi desativada."*
  - `user-not-found` / `wrong-password` / `invalid-credential` → *"E-mail ou senha incorretos."*
  - `email-already-in-use` → *"Este e-mail já está cadastrado."*
  - `weak-password` → *"Senha fraca. Use pelo menos 6 caracteres."*

---

## 🗄️ Banco de Dados (Cloud Firestore)

### Estrutura de Documentos
Os dados são estruturados por usuário para garantir isolamento e segurança:
`users/{uid}/books/{bookId}`

### Campos do Documento `Book`
- `title` (String): Título do livro.
- `author` (String): Autor do livro.
- `status` (String): `"wantToRead"`, `"reading"` ou `"read"`.
- `totalPages` (int): Total de páginas (> 0).
- `currentPage` (int): Página atual (0 para *wantToRead*, totalPages para *read*).
- `rating` (int?): Nota de 1 a 5 (preenchido apenas quando *read*).
- `finishedAt` (Timestamp?): Data de conclusão (preenchido apenas quando *read*).
- `createdAt` (Timestamp): Data de criação do registro no banco.

> 💡 **Nota de Performance:** A listagem no `DatabaseService` é ordenada por `createdAt` decrescente (`orderBy('createdAt', descending: true)`). O filtro por status é realizado localmente no app, evitando a necessidade de criar índices compostos no Firestore.

### Regras de Segurança (Firestore Rules)
As regras abaixo devem ser publicadas no console do Firebase para garantir o acesso exclusivo de cada usuário aos seus próprios registros:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid}/books/{bookId} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
  }
}
```

---

## 🚀 Como Executar o Projeto

### Pré-requisitos
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versão estável mais recente)
- [Node.js](https://nodejs.org/) (para instalação das ferramentas do Firebase)
- Emulador Android/iOS ou dispositivo físico configurado

### Passo a Passo

1. **Clonar o repositório e obter as dependências:**
   ```bash
   git clone <URL_DO_REPOSITORIO>
   cd estante_leitura
   flutter pub get
   ```

2. **Configurar o Firebase Console:**
   - Acesse [console.firebase.google.com](https://console.firebase.google.com/).
   - Crie um projeto chamado **`estante-leitura`**.
   - Em **Authentication → Sign-in method**, ative o provedor **E-mail/senha**.
   - Em **Firestore Database**, crie o banco de dados no modo produção (recomendado selecionar a região `southamerica-east1`).
   - Cole e publique as **Regras de Segurança** descritas na seção anterior na aba *Regras*.

3. **Conectar o aplicativo ao Firebase:**
   Instale as ferramentas do Firebase CLI e FlutterFire no seu terminal:
   ```bash
   npm install -g firebase-tools
   firebase login
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

> ⚠️ **ATENÇÃO:** O arquivo `lib/firebase_options.dart` é específico para cada projeto Firebase. Quem clonar este repositório **DEVE obrigatoriamente executar `flutterfire configure`** para gerar as chaves e IDs referentes ao seu próprio projeto Firebase.

4. **Executar a aplicação:**
   ```bash
   flutter run
   ```

---

## 📸 Capturas de Tela

| Tela de Login | Tela de Cadastro | Estante (Home) | Formulário de Livro |
| :---: | :---: | :---: | :---: |
| <img width="250" alt="Tela de Login" src="https://github.com/user-attachments/assets/e05498ad-2688-48b0-b012-95d30ebe875e" /> | <img width="250" alt="Tela de Cadastro" src="https://github.com/user-attachments/assets/b761abf6-c212-4c6e-9ae4-51307d8bb21f" /> | <img width="250" alt="Estante" src="https://github.com/user-attachments/assets/2799c55a-004f-411d-b54b-0ee53ed63c94" /> | <img width="250" alt="Formulário" src="https://github.com/user-attachments/assets/db4687b6-8e4d-42ff-9795-8e3ff6b19e4e" /> |
---

## 👨‍💻 Autor

Desenvolvido para fins acadêmicos. Projeto **Alexandria - Estante de Leitura** por Pedro Henrique Martins Silva.
