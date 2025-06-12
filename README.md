# AMUZ TODO - Todo List App

## 1. 프로젝트 소개

AmuzTodo는 Flutter 프레임워크를 사용하여 개발된 직관적인 Todo List 애플리케이션입니다. Supabase를 백엔드로 활용하여 사용자 인증, 데이터베이스, 이미지 저장 등의 기능을 구현하였으며, Riverpod를 통한 상태 관리로 코드의 안정성과 확장성을 높였습니다.

**주요 기능:**

- 이메일 기반 회원가입 및 로그인
- 할 일 목록 조회, 추가, 수정, 삭제 (CRUD)
- 미완료/완료한 할 일, 태그별 필터 기능, 검색 기능
- 이미지 첨부 기능(프로필 사진, 할 일의 사진)
- 다크 모드 지원

## 2. 아키텍처 및 상태관리

이 프로젝트는 명확한 관심사 분리를 위해 MVVM (Model-View-ViewModel) 아키텍처와 Repository 패턴을 기반으로 설계되었습니다. 상태 관리는 Riverpod를 사용합니다.

### 2.1. 프로젝트 파일 구조

프로젝트의 핵심 구조는 `lib` 디렉토리 내에 있으며, 각 계층의 역할은 다음과 같습니다.

```bash
lib/
├── main.dart       # 앱 시작점
├── src/
│   ├── model/      # 데이터 모델 (Todo, User 등)
│   ├── repository/ # 데이터 소스(Supabase) 통신
│   ├── service/    # 비즈니스 로직 (ViewModel)
│   └── view/       # UI (화면)
├── theme/          # 앱 테마 및 스타일
└── util/           # 공통 유틸리티 함수
```

- **`src/view/`**: UI와 사용자 상호작용을 처리합니다. `ConsumerWidget` 또는 `ConsumerStatefulWidget`을 사용하여 ViewModel(`service`)의 상태 변화를 구독하고, UI를 갱신합니다.
- **`src/service/`**: View와 Repository를 연결하는 비즈니스 로직 계층(ViewModel)입니다. Riverpod의 `Notifier`를 사용하여 UI 상태를 관리하고, Repository로부터 데이터를 요청하거나 가공하는 역할을 합니다.
- **`src/repository/`**: 데이터 소스(이 프로젝트에서는 Supabase)와의 통신을 담당합니다. 데이터의 CRUD(생성, 조회, 수정, 삭제) 작업을 추상화하여 구체적인 데이터 소스 구현에 의존하지 않도록 합니다.
- **`src/model/`**: 애플리케이션에서 사용하는 데이터 모델(예: `Todo`, `User`, `Tag`)을 정의합니다.
- **`theme/`, `util/`**: 앱 전반에서 사용되는 테마, 스타일, 공통 함수 등을 관리합니다.

### 2.2. 상태관리 (Riverpod)

Riverpod는 의존성 주입과 상태 관리를 위해 프로젝트 전반에서 사용됩니다. View는 `ref.watch`를 통해 ViewModel(`service`)의 상태를 구독하고, `ref.read`를 통해 ViewModel의 함수를 호출하여 상태를 변경합니다.

아래는 `TodoListView`에서 Riverpod를 활용하는 실제 코드 예시입니다.

**`lib/src/view/todo/list/todo_list_view.dart`**

```dart
// ... imports ...

class _TodoListViewState extends ConsumerState<TodoListView> {
  @override
  Widget build(BuildContext context) {
    // 1. ref.watch로 ViewModel의 상태 변화를 구독합니다.
    final todoListState = ref.watch(todoListViewModelProvider);

    return Scaffold(
      // ...
      body: Column(
        children: [
          FilterButtonsRow(
            // ...
            // 2. 사용자 입력에 따라 ViewModel의 함수를 호출합니다.
            onCompletionFilterChanged: (filter) => ref
                .read(todoListViewModelProvider.notifier)
                .setCompletionFilter(filter),
          ),
          Expanded(
            // 3. ViewModel의 상태에 따라 UI를 렌더링합니다.
            child: todoListState.status == TodoListViewStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(...)
          ),
        ],
      ),
    );
  }
}
```

이러한 패턴을 통해 View는 UI 표시에만 집중하고, 복잡한 상태 관리와 비즈니스 로직은 ViewModel(`service`)이 담당하여 코드의 테스트 용이성과 유지보수성을 높입니다.

## 3. 설계 과정에서의 고민

이 프로젝트의 구조를 설계하며 다음과 같은 점들을 주로 고민했습니다.

### 3.1. 아키텍처와 상태 관리 선택에 대한 고민

MVVM 아키텍처를 선택한 이유는 View와 비즈니스 로직의 분리를 통해 코드의 테스트 용이성과 유지보수성을 확보하기 위함이었습니다. ViewModel(Service) 계층을 두어 View는 UI 표시에만 집중하게 하고, 복잡한 상태 관리와 비즈니스 로직은 ViewModel이 담당하도록 설계했습니다.

**상태 관리**로는 Riverpod을 선택했습니다. 앱 전역에서 사용되는 객체들을 Provider로 관리하면 `ref` 객체를 통해 쉽게 접근하고 상태를 동기화할 수 있어, 복잡한 상태 변화를 선언적이고 깔끔하게 처리할 수 있었습니다.

**가장 큰 이유는 학습 목적이었습니다.** 현재 수강 중인 Flutter 강의에서 MVVM + Repository + Riverpod 조합을 이론적으로 학습하고 있었는데, 강의 자료로 제공된 예제 프로젝트 구조를 실제 프로젝트에 직접 적용해보고 싶었습니다. 각 패턴이 실제 코드에서 어떤 장단점이 있는지를 직접 경험해보는 것이 중요하다고 생각했습니다.

### 3.2. 태그 모델 설계 중 결정사항

**데이터 모델링 측면**에서는 태그 저장 방식을 고민했습니다. 초기에는 `todos` 테이블에 텍스트 배열로 태그를 저장하는 방식을 고려했지만, 태그 중복 방지와 확장성을 위해 별도의 `tags` 테이블과 `todo_tags` 연결 테이블을 사용하는 정규화된 구조를 선택했습니다. 이를 통해 태그 자동완성 기능과 태그별 메타데이터 확장이 용이해졌습니다.

**상태 관리 설계**에서는 선택된 태그의 타입을 결정해야 했습니다. 초기에는 단순한 `List<String>`을 고려했지만, 일관성과 타입 안전성을 위해 `List<Tag>` 객체를 사용하기로 했습니다. 이는 `availableTags`와 동일한 타입으로 통일되어 코드 일관성을 높이고, 컴파일 타임에 타입 검증이 가능해졌습니다.

**태그 생성 시점**에 대해서는 Todo 저장 시 지연 생성하는 방식과 + 버튼 클릭 시 즉시 생성하는 방식을 비교했습니다. 사용자 피드백의 즉시성과 일관된 데이터 구조를 위해 즉시 생성 방식을 선택했습니다.

**Repository 설계**에서는 현재 앱 규모와 학습 목적을 고려하여 단일 `TodoRepository`를 유지하되, 향후 필요시 분리할 수 있는 구조로 설계했습니다. 이를 통해 과도한 복잡성 없이 빠른 기능 구현과 검증이 가능했습니다.

## 4. 실행 방법

### 4.1. 사전 준비

- Flutter SDK 설치
- IDE (VS Code, Android Studio 등) 설치

### 4.2. 프로젝트 설정

1.  **저장소 복제 (Clone)**

    ```bash
    git clone https://github.com/your-username/amuz_todo.git
    cd amuz_todo
    ```

2.  **Supabase 환경 변수 설정**
    프로젝트 루트 디렉토리에 `.env` 파일을 생성하고, 본인의 Supabase 프로젝트 정보를 입력합니다.

    **.env**

    ```
    SUPABASE_URL=YOUR_SUPABASE_URL
    SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
    ```

3.  **의존성 설치**
    ```bash
    flutter pub get
    ```

### 4.3. 앱 실행

```bash
flutter run
```

## 5. 구현 사항

### 5.1. 페이지

- **사용자 정보 설정 페이지**
  - 이름, 프로필 사진 등록 (앱 내 설정 페이지 상단 프로필 카드 영역에 위치)
- **Todo List 페이지**
  - Todo 삭제 기능, 필터 기능, 검색 기능
- **Todo 상세 페이지**
  - Todo 삭제 기능, 수정 기능
- **Todo 추가 페이지**
  - 추가하려던 내용의 임시 저장 기능
  - 임시 저장된 항목이 있는 상태에서 페이지 진입 시 사용자에게 물어보도록 구성

### 5.2. 모델

- **Todo**: 할 일 데이터를 관리하는 핵심 모델

  - `id` (String): 고유 식별자
  - `userId` (String): 작성한 사용자의 ID
  - `title` (String): 할 일의 제목
  - `content` (String?): 할 일의 상세 내용 (선택 사항)
  - `imageUrl` (String?): 첨부된 이미지의 URL (선택 사항)
  - `isCompleted` (bool): 완료 여부 (기본값 `false`)
  - `priority` (Priority): 우선순위 (`low`, `medium`, `high`, 기본값 `medium`)
  - `dueDate` (DateTime?): 마감 기한 (선택 사항)
  - `tags` (List<Tag>): 할 일에 부여된 태그 목록
  - `createdAt` (DateTime): 생성 시각
  - `updatedAt` (DateTime): 마지막 수정 시각

- **Tag**: 할 일에 분류를 위해 사용되는 태그 모델

  - `id` (String): 고유 식별자
  - `name` (String): 태그 이름
  - `createdAt` (DateTime): 생성 시각

- **User**: 사용자 정보를 담는 모델

  - `id` (String): 사용자 고유 ID (Supabase Auth UID와 연결)
  - `name` (String?): 사용자 이름 (선택 사항)
  - `profileImageUrl` (String?): 프로필 이미지 URL (선택 사항)
  - `createdAt` (DateTime): 계정 생성 시각

- **Priority**: 할 일의 우선순위를 나타내는 `enum` (`low`, `medium`, `high`)

### 5.3. 데이터베이스 스키마 (Supabase)

```bash
Database Schema (Supabase)
├── user_profiles/          # 사용자 프로필 테이블
│   ├── id (uuid, PK)      # 고유 식별자 → auth.users.id 참조
│   ├── email (text)       # 사용자 이메일
│   ├── name (text)        # 사용자 이름
│   ├── profile_image_url (text)  # 프로필 이미지 URL
│   ├── created_at (timestampz)   # 생성 시각
│   └── updated_at (timestampz)   # 수정 시각
│
├── todos/                  # 할 일 테이블
│   ├── id (uuid, PK)      # 고유 식별자
│   ├── user_id (uuid, FK) # 사용자 ID → auth.users.id 참조
│   ├── title (text)       # 할 일 제목
│   ├── description (text) # 할 일 설명
│   ├── image_url (text)   # 첨부 이미지 URL
│   ├── is_completed (bool) # 완료 여부
│   ├── priority (int4)    # 우선순위 (0: low, 1: medium, 2: high)
│   ├── due_date (timestampz)     # 마감 기한
│   ├── created_at (timestampz)   # 생성 시각
│   └── updated_at (timestampz)   # 수정 시각
│
├── tags/                   # 태그 테이블
│   ├── id (uuid, PK)      # 고유 식별자
│   ├── name (text)        # 태그 이름
│   ├── user_id (uuid, FK) # 사용자 ID → auth.users.id 참조
│   └── created_at (timestampz)   # 생성 시각
│
└── todo_tags/              # 할 일-태그 연결 테이블 (다대다 관계)
   ├── todo_id (uuid, FK) # 할 일 ID → todos.id 참조
   ├── tag_id (uuid, FK)  # 태그 ID → tags.id 참조
   └── created_at (timestampz)   # 연결 생성 시각
```

### 5.4. 추가 구현 기능

- Todo 태그 필터 (할 일 목록 페이지에서 검색 필드 아래 가로 스크롤하여 사용 가능, 복수 선택 가능)
- 사진 첨부 기능 (할 일 추가/상세 페이지에서 설명 입력 필드 오른편에 위치)
- 다크 모드 대응 (설정 페이지에서 토글 전환)
- 마감일 설정 (할 일 추가 페이지에서 설정 가능)
- 우선순위 설정 (할 일 추가 페이지에서 설정 가능)
- 마감일/우선순위/생성일 기반 정렬 기능 (할 일 목록 페이지 앱 바 leading에서 아이콘 버튼)
- 회원가입 및 로그인 기능 (초기 진입 시 라우팅)

## 6. 사용된 기술

- **Flutter 버전**: 3.22.2
- **플랫폼**: Android, iOS (개발 과정에서는 iPhone 16 화면 사이즈 기준으로 UI 작성)
- **상태관리**: Riverpod
- **데이터 저장**:
  - Local 임시 저장을 위한 SharedPreferences 사용
  - 원격 저장 방식 (Supabase를 활용한 REST API)
