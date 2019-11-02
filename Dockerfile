FROM bitnami/kubectl:latest
LABEL maintainer="gizmotronic@gmail.com"

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]
