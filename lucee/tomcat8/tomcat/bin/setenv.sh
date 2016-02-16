# Tomcat memory settings
# -Xms<size> set initial Java heap size
# -Xmx<size> set maximum Java heap size
CATALINA_OPTS="-Xms256m -Xmx512m -javaagent:lib/lucee-inst.jar";

# additional JVM arguments can be added to the above line as needed, such as
# custom Garbage Collection arguments.

export CATALINA_OPTS;
