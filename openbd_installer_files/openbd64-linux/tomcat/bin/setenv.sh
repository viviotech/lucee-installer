# Tomcat memory settings
# -Xms<size> set initial Java heap size
# -Xmx<size> set maximum Java heap size
# -Xss<size> set java thread stack size
# -XX:MaxPermSize sets the java PermGen size
JAVA_OPTS="-Xms128m -Xmx256m -XX:MaxPermSize=64m ";   # memory settings

export JAVA_OPTS;
