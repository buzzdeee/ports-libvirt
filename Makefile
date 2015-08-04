# $OpenBSD: Makefile,v 1.35 2015/07/14 23:28:59 jasper Exp $

COMMENT-main=		tool/library for managing platform virtualization
COMMENT-server=		daemon to manage platform virtualization

VERSION=		1.2.17
DISTNAME=		libvirt-${VERSION}
PKGNAME-main=		${DISTNAME}
PKGNAME-server=		libvirt-server-${VERSION}
CATEGORIES=		sysutils devel
REVISION=		60

SHARED_LIBS +=  virt-qemu                 0.3 # 1002.17
SHARED_LIBS +=  virt                      0.7 # 1002.17
SHARED_LIBS +=	virt-lxc		  0.0 # 1002.17
SHARED_LIBS +=	virt-admin                0.0 # 1002.17

HOMEPAGE=		https://libvirt.org/

MAINTAINER=		Jasper Lievisse Adriaanse <jasper@openbsd.org>

MASTER_SITES=		${HOMEPAGE}/sources/ \
			${HOMEPAGE}/sources/stable_updates/

# LGPLv2.1
PERMIT_PACKAGE_CDROM=   Yes

MULTI_PACKAGES=	-main -server

MODULES=		devel/gettext \
			lang/python

MODPY_RUNDEP=		No

WANTLIB += avahi-client avahi-common c crypto curl dbus-1
WANTLIB += gnutls hogweed idn m nettle p11-kit lzma
WANTLIB += pthread ssh2 ssl tasn1 util xml2 z ffi gmp
WANTLIB += kvm yajl
WANTLIB-main += ${WANTLIB} ncurses readline
WANTLIB-server += ${WANTLIB} virt virt-admin virt-lxc virt-qemu

BUILD_DEPENDS=		textproc/docbook

LIB_DEPENDS=		devel/libyajl \
			net/avahi \
			net/curl \
			security/gnutls \
			security/libssh2 \
			textproc/libxml
LIB_DEPENDS-server +=	${BUILD_PKGPATH}
RUN_DEPENDS-server +=	net/dnsmasq \
			sysutils/dmidecode

USE_GMAKE=		Yes

AUTOCONF_VERSION=	2.69
AUTOMAKE_VERSION=	1.15
CONFIGURE_STYLE=	autoconf automake gnu
CONFIGURE_ENV=		LDFLAGS=-L${LOCALBASE}/lib \
			FUSE_CFLAGS=-I/usr/include \
			FUSE_LIBS=-lfuse
CONFIGURE_ARGS+=	${CONFIGURE_SHARED} \
			--with-avahi \
			--with-ssh2 \
			--with-yajl \
			--with-fuse \
			--without-netcf \
			--with-network \
			--with-qemu-group=wheel \
			--without-sasl \
			--without-pm-utils
# OpenBSD can't act as a virtualization host, so no need for libvirtd.
# If support is added, subtitute /var/lib/{xen,virt,libvirt,...} with /var/db
#CONFIGURE_ARGS+=	--without-libvirtd

FAKE_FLAGS=		confdir=${PREFIX}/share/examples/libvirt \
			DOCS_DIR=${PREFIX}/share/doc/libvirt/python \
			EXAMPLE_DIR=${PREFIX}/share/doc/libvirt/python/examples \
			HTML_DIR=${PREFIX}/share/doc/libvirt/html

# nwfilters are only used by libvirtd, which is (currently) disabled on OpenBSD
FAKE_FLAGS+=		NWFILTER_DIR=${TMPDIR} \
			FILTERS=""

.include <bsd.port.mk>
