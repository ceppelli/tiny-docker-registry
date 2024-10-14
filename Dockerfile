FROM alpine:3.20

USER root
RUN ["mkdir", "/opt/docker"]

WORKDIR     /opt/docker

RUN apk add --no-cache ca-certificates

RUN set -eux; \
# https://github.com/distribution/distribution/releases
	version='3.0.0-beta.1'; \
	apkArch="$(apk --print-arch)"; \
	case "$apkArch" in \
		x86_64)  arch='amd64';   sha256='96344f15da3ddbef8cf300f9642d03a2b0a7aaa0b593dfe89a9ad266c5aa4ff4' ;; \
		aarch64) arch='arm64';   sha256='62e3e0c168f62ac274672446a3f6ea89ebdfedc6630e4b02d93900b7022dbe88' ;; \
		armhf)   arch='armv6';   sha256='01a5373d1e05bf539a1ddf5892c3bfa7377bbc02b340f6260eb7a3c62da99897' ;; \
		armv7)   arch='armv7';   sha256='fb3748b3108950ba3a0b2868f4cd2317ab308d7436944bdcd3ac62f734b68eb5' ;; \
		ppc64le) arch='ppc64le'; sha256='eccd060cf2d0d801fad27994d09aa43c945629cff7664f5d27bee9698b58f2a6' ;; \
		s390x)   arch='s390x';   sha256='b4c415a28c9d58453455068542e92b94b080dbbbc6e990f2360098a64756c71d' ;; \
		*) echo >&2 "error: unsupported architecture: $apkArch"; exit 1 ;; \
	esac; \
	wget -O /opt/docker/registry.tar.gz "https://github.com/distribution/distribution/releases/download/v${version}/registry_${version}_linux_${arch}.tar.gz"; \
	echo "$sha256 *registry.tar.gz" | sha256sum -c -; \
	tar --extract --verbose --file registry.tar.gz --directory /opt/docker/ registry; \
	rm /opt/docker/registry.tar.gz; \
	/opt/docker/registry --version

COPY docker/config-example.yml /etc/distribution/config.yml
COPY docker/entrypoint.sh /opt/docker/entrypoint.sh

VOLUME ["/var/lib/registry"]
EXPOSE 5000

RUN id -u demiourgos728 1>/dev/null 2>&1 || (( getent group 0 1>/dev/null 2>&1 || ( type groupadd 1>/dev/null 2>&1 && groupadd -g 0 root || addgroup -g 0 -S root )) && ( type useradd 1>/dev/null 2>&1 && useradd --system --create-home --uid 1001 --gid 0 demiourgos728 || adduser -S -u 1001 -G root demiourgos728 ))

RUN ["chmod", "-R", "u=rx,g=rx", "/opt/docker"]
RUN ["chown", "-R", "demiourgos728:root", "/opt/docker"]

USER 1001:0
ENTRYPOINT ["/opt/docker/entrypoint.sh"]

CMD ["/etc/distribution/config.yml"]