#===========
#Copyright 2022 Broadcom.  The term "Broadcom" refers solely to the 
#Broadcom Inc. corporate affiliate that distributes this software.
#===========
export LOG_LEVEL=INFO
 
export EM_INSTALL_HOME="/a/ibmuser/email2"
export EM_HOME="${EM_INSTALL_HOME}"
export JAVA_HOME="/usr/lpp/java/J8.0_64/"
 

export EM_DISCOVERY_HOST="host.company.com"
export EM_DISCOVERY_PORT="10000"
export EM_DISCOVERY_URL="https://${EM_DISCOVERY_HOST}:${EM_DISCOVERY_PORT}/eureka"
 
export KEYPASSWORD="password"
export STORETYPE="PKCS12"

 
export EM_HOST="host.company.com"
export EM_HOST_IP="127.0.0.1"
export EM_SYSNAME="SYS1"

export EM_EMAIL_PORT="10004"
 
CLASSPATH="."
export CLASSPATH="${CLASSPATH}"
 
PATH=/bin:/usr/sbin/:"${JAVA_HOME}"/bin
export PATH
 
LIBPATH=/lib:/usr/lib:"${JAVA_HOME}"/bin
LIBPATH="$LIBPATH":"${JAVA_HOME}"/bin/classic
LIBPATH="$LIBPATH":"${JAVA_HOME}"/bin/j9vm
LIBPATH="$LIBPATH":"${JAVA_HOME}"/lib/s390x
LIBPATH="$LIBPATH":"${JAVA_HOME}"/lib/s390x/classic
LIBPATH="$LIBPATH":"${JAVA_HOME}"/lib/s390x/default
LIBPATH="$LIBPATH":"${JAVA_HOME}"/lib/s390x/j9vm
LIBPATH="$LIBPATH":"${EM_INSTALL_HOME}"/libMUSER
export LIBPATH="${LIBPATH}"

IJO="$IJO -Deureka.client.serviceUrl.defaultZone=${EM_DISCOVERY_URL}"
IJO="$IJO -Dserver.hostname=${EM_HOST}"
IJO="$IJO -Dserver.address=${EM_HOST_IP}"
IJO="$IJO -Dfile.encoding=UTF-8"
IJO="$IJO -Dserver.ssl.enabled=true"
#Keystore
IJO="$IJO -Dserver.ssl.keyPassword=${KEYPASSWORD}"
IJO="$IJO -Dserver.ssl.keyStoreType=${STORETYPE}"
IJO="$IJO -Dserver.ssl.trustStorePassword=${KEYPASSWORD}"
IJO="$IJO -Dserver.ssl.keyStorePassword=${KEYPASSWORD}"
IJO="$IJO -Dserver.ssl.trustStoreType=${STORETYPE}"
#IJO="$IJO -Djava.protocol.handler.pkgs=com.ibm.crypto.provider"
#
IJO="$IJO -Dserver.ssl.keyAlias=localhost"
IJO="$IJO -Dserver.ssl.keyStore=${EM_INSTALL_HOME}/keystore/localhost/localhost.keystore.p12"
IJO="$IJO -Dserver.ssl.trustStore=${EM_INSTALL_HOME}/keystore/localhost/localhost.truststore.p12"
#

IJO="$IJO -Dzowe.commons.security.logout.repository.type=inMemory"
IJO="$IJO -Dapiml.security.ssl.verifySslCertificatesOfServices=false"
 
export IJO="${IJO}"
export IBM_JAVA_OPTIONS="$IJO"
 
$EM_INSTALL_HOME/util/email.sh
