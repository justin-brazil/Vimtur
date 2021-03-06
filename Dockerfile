FROM simplyboo6/vimtur-base@sha256:f30cc178f6c9676449e08b0aee59e31c120eb5c467cb435c33fd2bedb230f593

ARG VERSION_NAME=dev

## Copy in source
COPY ./ /app/
RUN echo "$VERSION_NAME" > /app/version

## Build server
RUN cd /usr/lib/node_modules/phash2 && yarn link
RUN cd /app/server && \
    yarn link phash2 && \
    yarn --frozen-lockfile --network-timeout 1000000 && \
    yarn lint && yarn build && \
    yarn install --production --frozen-lockfile --network-timeout 1000000

## Build client
RUN cd /app/client && \
    yarn --frozen-lockfile --network-timeout 1000000 && \
    yarn lint && yarn build:prod && \
    yarn install --production --frozen-lockfile --network-timeout 1000000

WORKDIR /app

ENTRYPOINT [ "/sbin/tini", "--", "node", "/app/server/dist/index.js" ]
