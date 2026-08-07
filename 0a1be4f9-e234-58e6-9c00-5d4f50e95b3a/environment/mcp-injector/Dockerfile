FROM python:3.12-slim@sha256:d657ab0ade19f404a6ccc883ab399540de667aff751748ce23c07330c5a89e64
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY injector.py .
EXPOSE 9000
CMD ["uvicorn", "injector:app", "--host", "0.0.0.0", "--port", "9000"]
