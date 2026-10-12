FROM ghcr.io/cirruslabs/flutter:3.47.7 AS build

ARG SUPABASE_URL
ARG SUPABASE_ANON_KEY
ARG SUPABASE_SITE_URL
ARG GOOGLE_CLIENT_ID

WORKDIR /app
COPY app/ /app/

RUN flutter build web --release \
  --dart-define=SUPABASE_URL=${SUPABASE_URL} \
  --dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY} \
  --dart-define=SUPABASE_SITE_URL=${SUPABASE_SITE_URL} \
  --dart-define=GOOGLE_CLIENT_ID=${GOOGLE_CLIENT_ID}

FROM nginx:1.26.3

COPY --from=build /app/build/web /usr/share/nginx/html
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

ENV PORT=8080
EXPOSE 8080
