PORTNAME=	ocijail
DISTVERSION=	0.2.0
PORTREVISION=	1
CATEGORIES=	sysutils

MAINTAINER=	dfr@FreeBSD.org
COMMENT=	Experimental, proof-of-concept OCI-compatible runtime for jails
WWW=		https://github.com/dfr/ocijail

LICENSE=	BSD3CLAUSE

IGNORE_FreeBSD_12= Not supported on FreeBSD 12 (uses c++20)

USE_GITHUB=	yes
GH_ACCOUNT=	davidchisnall
GH_TAGNAME=	bad3a82


PLIST_FILES=	bin/ocijail

BUILD_DEPENDS=	\
	${LOCALBASE}/include/nlohmann/json.hpp:devel/nlohmann-json \
	${LOCALBASE}/include/CLI/CLI.hpp:devel/cli11


USES=	cmake

.include <bsd.port.mk>
