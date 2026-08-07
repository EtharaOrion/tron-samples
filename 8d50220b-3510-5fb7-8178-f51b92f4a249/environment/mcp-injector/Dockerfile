FROM python:3.12-slim@sha256:646fb0bca3dd3ea1bcc6feb72c17ed16eed6e10cffc732fcc1478bd3e7f02d7b
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY injector.py .
EXPOSE 9000
CMD ["uvicorn", "injector:app", "--host", "0.0.0.0", "--port", "9000"]
