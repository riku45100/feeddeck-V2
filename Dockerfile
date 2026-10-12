FROM debian:bookworm-slim AS build

ARG FLUTTER_VERSION=3.47.7
ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG SUPABASE_SITE_URL
ARG GOOGLE_CLIENT_ID

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    xz-utils \
  && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL \
    https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz \
    | tar -xJ -C /opt

ENV PATH="/opt/flutter/bin:${PATH}"
RUN flutter config --no-analytics && flutter precache --web

WORKDIR /app
COPY app/ /app/

RUN flutter pub get && flutter build web --release \
  --dart-define=SUPABASE_URL=${SUPABASE_URL} \
  --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY} \
  --dart-define=SUPABASE_SITE_URL=${SUPABASE_SITE_URL} \
  --dart-define=GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}

FROM nginx:1.26.3

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

ENV PORT=8080
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
