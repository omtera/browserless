# Base images are pinned by digest (checked 2026-11-14) so an upstream release can never
# break a user's deploy unannounced. The browserless digest is the build verified on
# Railway that day. To upgrade, replace a digest with a newer one and test a deploy.
FROM alpine:3.24@sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf AS parallel

RUN apk add --no-cache parallel

FROM caddy:2.11@sha256:4e2425f6009577e7c651010f16679c28f7d12df3e7b1914f941a7a3370746b3c AS caddy

COPY Caddyfile ./

RUN caddy fmt --overwrite Caddyfile

FROM ghcr.io/browserless/chrome:latest@sha256:8fe0f3a08a857dd6787d8e16629330eb912017d616ab81b1a1e7920731731412

COPY --from=caddy /srv/Caddyfile ./

COPY --from=caddy /usr/bin/caddy /usr/bin/caddy

COPY --from=parallel /usr/bin/parallel /usr/bin/parallel

COPY --chmod=755 scripts/* ./

ENTRYPOINT ["/bin/sh"]

CMD ["start.sh"]