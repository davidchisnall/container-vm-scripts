PORTNAME=	qemufwcfg-fusefs
DISTVERSION=	0.1
CATEGORIES=	sysutils

LICENSE=	BSD2CLAUSE

MAINTAINER=	theraven@FreeBSD.org
COMMENT=	QEMU firmware config driver and filesystem
WWW=		https://github.com/davidchisnall/qemufwcfg/tree/main

USE_GITHUB=	yes
GH_ACCOUNT=	davidchisnall
GH_PROJECT=	qemufwcfg
GH_TAGNAME=	d67e278

USES=		fakeroot

USE_RC_SUBR=	qemufwcfg

LIB_DEPENDS=	libfuse.so:sysutils/fusefs-libs

BUILD_WRKSRC=	${WRKSRC}/mount_qemufwcfg
INSTALL_WRKSRC=	${WRKSRC}/mount_qemufwcfg

MAKE_ENV+=	BINDIR="${PREFIX}/bin" \
		MANDIR="${PREFIX}/share/man/man"

pre-install:
	${MKDIR} -p ${STAGEDIR}${PREFIX}/bin ${STAGEDIR}${PREFIX}/share/man/man8 ${STAGEDIR}/var/run/qemufwcfg


.include <bsd.port.mk>
