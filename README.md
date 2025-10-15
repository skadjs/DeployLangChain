## PDF RAG 질의응답 시스템

LangChain과 OpenAI를 활용한 PDF 문서 기반 질의응답 시스템입니다. PDF 파일을 업로드하면 AI가 문서 내용을 바탕으로 질문에 답변해드립니다.

###  주요 기능

- **PDF 문서 처리**: PyPDF를 이용한 PDF 파일 텍스트 추출
- **벡터 검색**: FAISS를 이용한 고속 유사도 검색
- **RAG 체인**: LangChain을 이용한 검색 증강 생성
- **웹 인터페이스**: Gradio를 이용한 직관적인 채팅 UI
- **Docker 지원**: 컨테이너화된 배포 환경

###  시스템 요구사항

- Python 3.12+
- OpenAI API 키
- Docker (선택사항)

###  프로젝트 구조

```
deploy-langchain/
├── src/
│   ├── deploy_langchain/
│   │   ├── __init__.py           # 패키지 초기화
│   │   └── main_pdf_rag.py       # 기존 통합 파일 (백업)
│   ├── main.py                   # 메인 실행 파일
│   ├── rag_service.py           # RAG 처리 로직
│   └── ui_interface.py          # Gradio UI 로직
├── uploads/                      # PDF 업로드 폴더
├── tests/                       # 테스트 파일
├── pyproject.toml               # 의존성 관리
├── Dockerfile                   # Docker 이미지 빌드
├── docker-compose.yml           # Docker Compose 설정
├── .dockerignore               # Docker 제외 파일
├── .env                        # 환경변수 (생성 필요)
└── README.md                   # 프로젝트 문서
```

### 코드 구조 설명

#### 1. `src/rag_service.py`
RAG(Retrieval-Augmented Generation) 처리를 담당하는 핵심 모듈입니다.

**주요 클래스: `PDFRAGService`**
- `load_pdf_to_vectorstore()`: PDF 파일을 벡터 저장소로 변환
- `get_answer()`: 질문에 대한 답변 생성
- `is_pdf_loaded()`: PDF 로드 상태 확인
- `clear_vectorstore()`: 벡터 저장소 초기화

#### 2. `src/ui_interface.py`
Gradio를 이용한 웹 인터페이스를 구성하는 모듈입니다.

**주요 클래스: `PDFChatInterface`**
- `create_interface()`: Gradio UI 컴포넌트 생성
- `respond()`: 사용자 입력 처리 및 응답
- `process_pdf_and_answer()`: PDF 처리 및 답변 로직 연결

#### 3. `src/main.py`
애플리케이션의 진입점으로 환경 감지 및 서버 설정을 담당합니다.

**주요 기능:**
- Docker/로컬 환경 자동 감지
- 서버 설정 및 애플리케이션 시작

### 설치 및 실행

### # 방법 1: 로컬 환경에서 실행

#### 1. 저장소 클론
```bash
git clone <repository-url>
cd deploy-langchain
```

#### 2. 의존성 설치
```bash
# Poetry 사용 (권장)
pip install poetry
poetry install

# 또는 pip 직접 사용
pip install python-dotenv langchain langchain-openai langchain-community pypdf gradio gradio-pdf faiss-cpu
```

#### 3. 환경변수 설정
```bash
# .env 파일 생성
echo "OPENAI_API_KEY=your-actual-api-key-here" > .env
```

#### 4. 애플리케이션 실행
```bash
# src 디렉토리에서 실행
cd src
python main.py

# 또는 프로젝트 루트에서 실행
python src/main.py
```

#### 5. 브라우저에서 접속
```
http://localhost:7860
```

### 방법 2: Poetry를 이용한 실행

#### 1. Poetry 환경에서 실행
```bash
poetry shell
cd src
python main.py
```

## Docker를 이용한 실행

### 사전 준비

#### 1. .env 파일 생성
```bash
echo "OPENAI_API_KEY=your-actual-api-key-here" > .env
```

### Docker 빌드 및 실행

#### 방법 1: Docker 명령어 사용
```bash
# 1. Docker 이미지 빌드
docker build -t user/pdf-rag-app:0.1 .

# 2. 컨테이너 실행
docker run -p 7860:7860 --env-file .env --name pdf-rag-app user/pdf-rag-app:0.1

# 3. 브라우저에서 접속
# http://localhost:7860
```

#### 방법 2: Docker Compose 사용
```bash
# 1. 백그라운드에서 실행
docker-compose up -d

# 2. 중지
docker-compose down

# 3. 완전 정리 (볼륨 포함)
docker-compose down -v
```

### Docker 환경 관리

#### 컨테이너 상태 확인
```bash
# 실행 중인 컨테이너 확인
docker ps

# 모든 컨테이너 확인
docker ps -a

# 컨테이너 로그 확인
docker logs user/pdf-rag:0.1
```

#### 이미지 관리
```bash
# 이미지 목록 확인
docker images

# 이미지 삭제
docker rmi user/pdf-rag:0.1

# 캐시 없이 다시 빌드
docker build --no-cache -t user/pdf-rag:0.1 .
```

## AWS EC2 배포

### 1. EC2 인스턴스 준비
```bash
# Docker 설치
sudo apt update
sudo apt install -y docker.io docker-compose
sudo usermod -aG docker $USER
```

### 2. 환경변수 관리 방법

#### 방법 A: 직접 .env 파일 생성
```bash
echo "OPENAI_API_KEY=your-api-key" > .env
```

#### 방법 B: AWS Parameter Store 사용 (권장)
```bash
# AWS CLI로 파라미터 저장
aws ssm put-parameter \
    --name "/pdf-rag/openai-api-key" \
    --value "your-api-key" \
    --type "SecureString" \
    --region us-east-1

# 파라미터에서 환경변수 가져오기
export OPENAI_API_KEY=$(aws ssm get-parameter \
    --name "/pdf-rag/openai-api-key" \
    --with-decryption \
    --query 'Parameter.Value' \
    --output text \
    --region us-east-1)
```

### 3. 배포 실행
```bash
# 소스 코드 업로드 후
docker-compose up -d

# 외부 접속을 위한 보안 그룹 설정 필요 (포트 7860)
```

## 사용법

### 1. PDF 업로드
- 왼쪽 패널에서 "PDF 파일 업로드" 버튼 클릭
- 분석하고 싶은 PDF 파일 선택

### 2. 고급 설정 (선택사항)
- **청크 크기**: 텍스트 분할 단위 (기본: 1000)
- **청크 중복**: 청크 간 중복 문자 수 (기본: 200)
- **창의성 수준**: AI 답변의 창의성 조절 (기본: 0.0)

### 3. 질문하기
- 오른쪽 채팅 창에서 문서에 대한 질문 입력
- "질문하기" 버튼 클릭 또는 Enter 키 입력

### 4. 예시 질문 활용
- 하단의 예시 질문 버튼을 클릭하여 빠른 시작

## API 사용량 및 비용

- **OpenAI API 사용**: GPT-3.5-turbo + text-embedding-3-small
- **예상 비용**: 
  - 텍스트 임베딩: $0.00002/1K tokens
  - GPT-3.5-turbo: $0.0015/1K tokens (입력) + $0.002/1K tokens (출력)

##  트러블슈팅

### 일반적인 문제

#### 1. OpenAI API 키 오류
```bash
# 환경변수 확인
echo $OPENAI_API_KEY

# .env 파일 확인
cat .env
```

#### 2. Docker 빌드 실패
```bash
# 캐시 없이 빌드
docker build --no-cache -t pdf-rag-app .

# 로그 확인
docker-compose logs
```

#### 3. 메모리 부족
```bash
# Docker 메모리 제한 늘리기
docker run -m 4g -p 7860:7860 --env-file .env pdf-rag-app
```

#### 4. 포트 충돌
```bash
# 다른 포트 사용
docker run -p 8080:7860 --env-file .env pdf-rag-app
```

### 로그 확인
```bash
# Docker 컨테이너 로그
docker logs pdf-rag-container

# Docker Compose 로그
docker-compose logs -f

# 실시간 로그 모니터링
docker logs -f pdf-rag-container
```

- [LangChain](https://langchain.com/) - RAG 구현 프레임워크
- [Gradio](https://gradio.app/) - 웹 인터페이스 라이브러리
- [FAISS](https://faiss.ai/) - 벡터 검색 엔진
- [OpenAI](https://openai.com/) - LLM 및 임베딩 모델