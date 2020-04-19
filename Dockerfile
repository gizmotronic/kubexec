ARG FROM_IMAGE_TAG="latest"
FROM bitnami/kubectl:$FROM_IMAGE_TAG
LABEL maintainer="gizmotronic@gmail.com"

COPY entrypoint.sh /

ENTRYPOINT [ "/entrypoint.sh" ]
