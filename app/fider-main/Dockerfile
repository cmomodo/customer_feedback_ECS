# syntax=docker/dockerfile:1

#####################
### Server Build Step
#####################
#Builder Stage
FROM golang:1.24-bookworm AS server-builder

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    libc6-dev

RUN mkdir /server
WORKDIR /server

COPY go.mod go.sum ./
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download

COPY Makefile main.go tools.go ./
COPY app ./app

ARG COMMITHASH
ARG VERSION
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    COMMITHASH=${COMMITHASH} VERSION=${VERSION} GOOS=${TARGETOS} GOARCH=${TARGETARCH} make build-server

# Prepare release artifacts to reduce layers in runtime
RUN mkdir -p /dist
COPY migrations /dist/migrations
COPY views /dist/views
COPY locale /dist/locale
COPY LICENSE favicon.png robots.txt /dist/
RUN cp fider /dist/fider

#################
### UI Build Step
#################
FROM node:22-bookworm AS ui-builder

WORKDIR /ui

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --maxsockets 1

COPY Makefile tsconfig.json webpack.config.js esbuild.config.js esbuild-shim.js lingui.config.js .babelrc index.d.ts ./
COPY public ./public
COPY locale ./locale

RUN make build-ssr build-ui

################
### Runtime Step
################
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && adduser --disabled-password --gecos "" fider \
    && mkdir -p /app \
    && chown -R fider:fider /app

WORKDIR /app
USER fider

COPY --chown=fider:fider --from=server-builder /dist /app
COPY --chown=fider:fider --from=ui-builder /ui/dist /app/dist
COPY --chown=fider:fider --from=ui-builder /ui/ssr.js /app/ssr.js

EXPOSE 3000

HEALTHCHECK --timeout=5s CMD ./fider ping

CMD ["sh", "-c", "./fider migrate && ./fider"]
