#===========
#Copyright 2022 Broadcom.  The term "Broadcom" refers solely to the 
#Broadcom Inc. corporate affiliate that distributes this software.
#===========
echo
echo "-------------------------------------------------------------------------------"
echo "Launching email.sh"
echo
 
export LOG_NAME=email
export JAR_PATH=${EM_INSTALL_HOME}/lib/email.jar

IJO="$IJO -Dspring.profiles.active=https"
IJO="$IJO -Dspringdoc.swagger-ui.csrf.enabled=true"
IJO="$IJO -Dserver.port=${EM_EMAIL_PORT}"
IJO="$IJO -Dapiml.enabled=true"
IJO="$IJO -Dapiml.service.ssl.keyAlias=xe69"
IJO="$IJO -Dapiml.service.ssl.keyStore=${EM_INSTALL_HOME}/keystore/localhost/localhost.keystore.p12"
IJO="$IJO -Dapiml.service.ssl.trustStore=${EM_INSTALL_HOME}/keystore/localhost/localhost.truststore.p12"
IJO="$IJO -Dapiml.service.hostname=${EM_HOST}"
IJO="$IJO -Dapiml.service.port=${EM_EMAIL_PORT}"
IJO="$IJO -Dapiml.service.discoveryServiceUrls=${EM_DISCOVERY_URL}"
IJO="$IJO -Djava.library.path=${EM_INSTALL_HOME}"


IJO="$IJO -Xms256m -Xmx1024m"
export IBM_JAVA_OPTIONS="${IJO}"
 
export STEPLIB=${EM_LIB}           

CLASSPATH="$CLASSPATH":"${JAR_PATH}"
export CLASSPATH="${CLASSPATH}"

java -jar "${JAR_PATH}" &
 
echo
status=$?
if test $status -ne 0
then
  echo "***  java -jar command, $JAR_PATH, failure:"
  echo "***  return code is $status"
  exit 12
else
  echo "java -jar command, $JAR_PATH, command completed successfully."
  exit 0
fi
 
