BlueDragon WEB-INF/lib README
=============================
This is the standard directory used by J2EE web applications for locating Java
library files. All ".jar" libraries found in this directory are automatically
added to the web application's classpath by the web container.

BlueDragon requires the following libraries:

   OpenBlueDragon.jar
   ColdFusionAdapter.jar
   commons-codec-1.3.jar
   commons-collections-3.1.jar
   commons-discovery.jar
   commons-httpclient-2.0.2.jar
   commons-io-1.2.jar
   commons-logging.jar
   jakarta-oro-2.0.8.jar
   javolution.jar
   jaxrpc.jar
   saaj.jar
   webservices.jar
   wsdl4j.jar
   xalan.jar

The following libraries are required if your webapp uses the CFCHART tag:

   jcommon-1.0.0.jar
   jfreechart-1.0.1.jar

The following libraries are required if your webapp uses the CFSEARCH tag:

   lucene-analyzers-2.0.0.jar
   lucene-core-2.0.0.jar
   lucene-highlighter-2.0.0.jar
   lucene-snowball-2.0.0.jar
   PDFBox-0.7.2.jar
   tm-extractors-0.4.jar

The following library is for the HtmlGetPrintableText() function
   jericho-html-2.6.jar

The following library is for the CFJAVASCRIPT tag
    yuicompressor-2.4.2.jar

The following libraries contain JDBC drivers; you can remove them before deploying
your web application if they're not needed:

   mysql.jar (MySQL)
   postgresql.jar (PostgreSQL)
   h2.jar (H2 Database)
   ojdbc14.jar (Oracle 10g)
