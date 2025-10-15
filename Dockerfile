# ---- 베이스 이미지 변경: alpine 사용 ----
FROM python:3.12-alpine AS builder

WORKDIR /app

# 알파인용 빌드 의존성
RUN apk add --no-cache \
    gcc \
    g++ \
    musl-dev \
    linux-headers

COPY pyproject.toml ./

# 모든 필수 패키지 설치
RUN pip install --no-cache-dir \
    "python-dotenv>=1.1.1,<2.0.0" \
    "langchain>=0.3.27,<0.4.0" \
    "langchain-openai>=0.3.35,<0.4.0" \
    "langchain-community>=0.3.31,<0.4.0" \
    "pypdf>=6.1.1,<7.0.0" \
    "gradio>=5.49.1,<6.0.0" \
    "gradio-pdf>=0.0.22,<0.0.23" \
    "faiss-cpu>=1.12.0,<2.0.0"

# Python 캐시 파일 정리
RUN find /usr/local -type f -name '*.pyc' -delete \
    && find /usr/local -type d -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true

# ---- 최종 이미지 ----
FROM python:3.12-alpine

WORKDIR /app

ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH=/app

# 빌드된 패키지 복사
COPY --from=builder /usr/local/lib/python3.12/site-packages /usr/local/lib/python3.12/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

COPY src/ ./src/

# 알파인용 사용자 설정
RUN adduser -D appuser && \
    mkdir -p /app/uploads && \
    chown -R appuser:appuser /app

USER appuser

EXPOSE 7860

CMD ["python", "src/main.py"]