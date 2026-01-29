# syntax=docker/dockerfile:1
FROM node:18-bullseye AS builder

WORKDIR /app

ENV NODE_ENV=production
ENV NODE_OPTIONS=--openssl-legacy-provider
ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    pkg-config \
    libxi-dev \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxfixes-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    mesa-common-dev \
  && rm -rf /var/lib/apt/lists/*

RUN corepack enable

COPY . .

RUN yarn install --immutable --mode=skip-build
RUN yarn install:example
RUN yarn workspaces foreach -At run stab

ARG MAPBOX_ACCESS_TOKEN="__MAPBOX_ACCESS_TOKEN__"
ARG DROPBOX_CLIENT_ID="__DROPBOX_CLIENT_ID__"
ARG MAPBOX_EXPORT_TOKEN="__MAPBOX_EXPORT_TOKEN__"
ARG CARTO_CLIENT_ID="__CARTO_CLIENT_ID__"
ARG FOURSQUARE_CLIENT_ID="__FOURSQUARE_CLIENT_ID__"
ARG FOURSQUARE_DOMAIN="__FOURSQUARE_DOMAIN__"
ARG FOURSQUARE_API_URL="__FOURSQUARE_API_URL__"
ARG FOURSQUARE_USER_MAPS_URL="__FOURSQUARE_USER_MAPS_URL__"

ENV MapboxAccessToken=$MAPBOX_ACCESS_TOKEN \
  DropboxClientId=$DROPBOX_CLIENT_ID \
  MapboxExportToken=$MAPBOX_EXPORT_TOKEN \
  CartoClientId=$CARTO_CLIENT_ID \
  FoursquareClientId=$FOURSQUARE_CLIENT_ID \
  FoursquareDomain=$FOURSQUARE_DOMAIN \
  FoursquareAPIURL=$FOURSQUARE_API_URL \
  FoursquareUserMapsURL=$FOURSQUARE_USER_MAPS_URL

ARG TARGETARCH
RUN set -e; \
  case "$TARGETARCH" in \
    amd64) esbuild_platform="linux-x64" ;; \
    arm64) esbuild_platform="linux-arm64" ;; \
    *) echo "Unsupported TARGETARCH: $TARGETARCH" && exit 1 ;; \
  esac; \
  esbuild_bin="/app/examples/demo-app/node_modules/@esbuild/${esbuild_platform}/bin/esbuild"; \
  if [ ! -x "$esbuild_bin" ]; then \
    echo "Missing esbuild binary at $esbuild_bin" && exit 1; \
  fi; \
  cd examples/demo-app && ESBUILD_BINARY_PATH="$esbuild_bin" yarn build

FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*

COPY --from=builder /app/examples/demo-app/dist /usr/share/nginx/html
COPY ./nginx.conf /etc/nginx/conf.d/default.conf
COPY ./deployment/env-init.sh /tmp/deployment/env-init.sh
RUN chmod +x /tmp/deployment/env-init.sh

EXPOSE 80
ENTRYPOINT ["/bin/sh","/tmp/deployment/env-init.sh"]
