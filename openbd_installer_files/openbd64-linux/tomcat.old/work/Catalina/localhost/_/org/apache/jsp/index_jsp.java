package org.apache.jsp;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;

public final class index_jsp extends org.apache.jasper.runtime.HttpJspBase
    implements org.apache.jasper.runtime.JspSourceDependent {

  private static final JspFactory _jspxFactory = JspFactory.getDefaultFactory();

  private static java.util.List _jspx_dependants;

  private javax.el.ExpressionFactory _el_expressionfactory;
  private org.apache.AnnotationProcessor _jsp_annotationprocessor;

  public Object getDependants() {
    return _jspx_dependants;
  }

  public void _jspInit() {
    _el_expressionfactory = _jspxFactory.getJspApplicationContext(getServletConfig().getServletContext()).getExpressionFactory();
    _jsp_annotationprocessor = (org.apache.AnnotationProcessor) getServletConfig().getServletContext().getAttribute(org.apache.AnnotationProcessor.class.getName());
  }

  public void _jspDestroy() {
  }

  public void _jspService(HttpServletRequest request, HttpServletResponse response)
        throws java.io.IOException, ServletException {

    PageContext pageContext = null;
    ServletContext application = null;
    ServletConfig config = null;
    JspWriter out = null;
    Object page = this;
    JspWriter _jspx_out = null;
    PageContext _jspx_page_context = null;


    try {
      response.setContentType("text/html");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, false, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      out = pageContext.getOut();
      _jspx_out = out;

      out.write("<!--\n");
      out.write("  Licensed to the Apache Software Foundation (ASF) under one or more\n");
      out.write("  contributor license agreements.  See the NOTICE file distributed with\n");
      out.write("  this work for additional information regarding copyright ownership.\n");
      out.write("  The ASF licenses this file to You under the Apache License, Version 2.0\n");
      out.write("  (the \"License\"); you may not use this file except in compliance with\n");
      out.write("  the License.  You may obtain a copy of the License at\n");
      out.write("\n");
      out.write("      http://www.apache.org/licenses/LICENSE-2.0\n");
      out.write("\n");
      out.write("  Unless required by applicable law or agreed to in writing, software\n");
      out.write("  distributed under the License is distributed on an \"AS IS\" BASIS,\n");
      out.write("  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n");
      out.write("  See the License for the specific language governing permissions and\n");
      out.write("  limitations under the License.\n");
      out.write("-->\n");
      out.write("<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n");
      out.write("<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\"\n");
      out.write("   \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">\n");
      out.write("\n");
      out.write("<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">\n");
      out.write("    <head>\n");
      out.write("    <title>");
      out.print( application.getServerInfo() );
      out.write("</title>\n");
      out.write("    <style type=\"text/css\">\n");
      out.write("    /*<![CDATA[*/\n");
      out.write("      body {\n");
      out.write("          color: #000000;\n");
      out.write("          background-color: #FFFFFF;\n");
      out.write("\t  font-family: Arial, \"Times New Roman\", Times, serif;\n");
      out.write("          margin: 10px 0px;\n");
      out.write("      }\n");
      out.write("\n");
      out.write("    img {\n");
      out.write("       border: none;\n");
      out.write("    }\n");
      out.write("    \n");
      out.write("    a:link, a:visited {\n");
      out.write("        color: blue\n");
      out.write("    }\n");
      out.write("\n");
      out.write("    th {\n");
      out.write("        font-family: Verdana, \"Times New Roman\", Times, serif;\n");
      out.write("        font-size: 110%;\n");
      out.write("        font-weight: normal;\n");
      out.write("        font-style: italic;\n");
      out.write("        background: #D2A41C;\n");
      out.write("        text-align: left;\n");
      out.write("    }\n");
      out.write("\n");
      out.write("    td {\n");
      out.write("        color: #000000;\n");
      out.write("\tfont-family: Arial, Helvetica, sans-serif;\n");
      out.write("    }\n");
      out.write("    \n");
      out.write("    td.menu {\n");
      out.write("        background: #FFDC75;\n");
      out.write("    }\n");
      out.write("\n");
      out.write("    .center {\n");
      out.write("        text-align: center;\n");
      out.write("    }\n");
      out.write("\n");
      out.write("    .code {\n");
      out.write("        color: #000000;\n");
      out.write("        font-family: \"Courier New\", Courier, monospace;\n");
      out.write("        font-size: 110%;\n");
      out.write("        margin-left: 2.5em;\n");
      out.write("    }\n");
      out.write("    \n");
      out.write("     #banner {\n");
      out.write("        margin-bottom: 12px;\n");
      out.write("     }\n");
      out.write("\n");
      out.write("     p#congrats {\n");
      out.write("         margin-top: 0;\n");
      out.write("         font-weight: bold;\n");
      out.write("         text-align: center;\n");
      out.write("     }\n");
      out.write("\n");
      out.write("     p#footer {\n");
      out.write("         text-align: right;\n");
      out.write("         font-size: 80%;\n");
      out.write("     }\n");
      out.write("     /*]]>*/\n");
      out.write("   </style>\n");
      out.write("</head>\n");
      out.write("\n");
      out.write("<body>\n");
      out.write("\n");
      out.write("<!-- Header -->\n");
      out.write("<table id=\"banner\" width=\"100%\">\n");
      out.write("    <tr>\n");
      out.write("      <td align=\"left\" style=\"width:130px\">\n");
      out.write("        <a href=\"http://tomcat.apache.org/\">\n");
      out.write("\t  <img src=\"tomcat.gif\" height=\"92\" width=\"130\" alt=\"The Mighty Tomcat - MEOW!\"/>\n");
      out.write("\t</a>\n");
      out.write("      </td>\n");
      out.write("      <td align=\"left\" valign=\"top\"><b>");
      out.print( application.getServerInfo() );
      out.write("</b></td>\n");
      out.write("      <td align=\"right\">\n");
      out.write("        <a href=\"http://jakarta.apache.org/\">\n");
      out.write("\t  <img src=\"asf-logo-wide.gif\" height=\"51\" width=\"537\" alt=\"The Apache Software Foundation\"/>\n");
      out.write("\t</a>\n");
      out.write("       </td>\n");
      out.write("     </tr>\n");
      out.write("</table>\n");
      out.write("\n");
      out.write("<table>\n");
      out.write("    <tr>\n");
      out.write("\n");
      out.write("        <!-- Table of Contents -->\n");
      out.write("        <td valign=\"top\">\n");
      out.write("            <table width=\"100%\" border=\"1\" cellspacing=\"0\" cellpadding=\"3\">\n");
      out.write("                <tr>\n");
      out.write("\t\t  <th>Administration</th>\n");
      out.write("                </tr>\n");
      out.write("                <tr>\n");
      out.write("\t\t  <td class=\"menu\">\n");
      out.write("\t\t    <a href=\"manager/status\">Status</a><br/>\n");
      out.write("                    <!--<a href=\"admin\">Tomcat&nbsp;Administration</a><br/>-->\n");
      out.write("                    <a href=\"manager/html\">Tomcat&nbsp;Manager</a><br/>\n");
      out.write("                    &nbsp;\n");
      out.write("                  </td>\n");
      out.write("                </tr>\n");
      out.write("            </table>\n");
      out.write("\n");
      out.write("\t    <br />\n");
      out.write("            <table width=\"100%\" border=\"1\" cellspacing=\"0\" cellpadding=\"3\">\n");
      out.write("                <tr>\n");
      out.write("\t\t  <th>Documentation</th>\n");
      out.write("                </tr>\n");
      out.write("                <tr>\n");
      out.write("                  <td class=\"menu\">\n");
      out.write("                    <a href=\"RELEASE-NOTES.txt\">Release&nbsp;Notes</a><br/>\n");
      out.write("                    <a href=\"docs/changelog.html\">Change&nbsp;Log</a><br/>\n");
      out.write("                    <a href=\"docs\">Tomcat&nbsp;Documentation</a><br/>                        &nbsp;\n");
      out.write("                    &nbsp;\n");
      out.write("\t\t    </td>\n");
      out.write("                </tr>\n");
      out.write("            </table>\n");
      out.write("\t    \n");
      out.write("            <br/>\n");
      out.write("            <table width=\"100%\" border=\"1\" cellspacing=\"0\" cellpadding=\"3\">\n");
      out.write("                <tr>\n");
      out.write("                  <th>Tomcat Online</th>\n");
      out.write("                </tr>\n");
      out.write("                <tr>\n");
      out.write("                  <td class=\"menu\">\n");
      out.write("                    <a href=\"http://tomcat.apache.org/\">Home&nbsp;Page</a><br/>\n");
      out.write("\t\t    <a href=\"http://tomcat.apache.org/faq/\">FAQ</a><br/>\n");
      out.write("                    <a href=\"http://tomcat.apache.org/bugreport.html\">Bug&nbsp;Database</a><br/>\n");
      out.write("                    <a href=\"http://issues.apache.org/bugzilla/buglist.cgi?bug_status=UNCONFIRMED&amp;bug_status=NEW&amp;bug_status=ASSIGNED&amp;bug_status=REOPENED&amp;bug_status=RESOLVED&amp;resolution=LATER&amp;resolution=REMIND&amp;resolution=---&amp;bugidtype=include&amp;product=Tomcat+5&amp;cmdtype=doit&amp;order=Importance\">Open Bugs</a><br/>\n");
      out.write("                    <a href=\"http://mail-archives.apache.org/mod_mbox/tomcat-users/\">Users&nbsp;Mailing&nbsp;List</a><br/>\n");
      out.write("                    <a href=\"http://mail-archives.apache.org/mod_mbox/tomcat-dev/\">Developers&nbsp;Mailing&nbsp;List</a><br/>\n");
      out.write("                    <a href=\"irc://irc.freenode.net/#tomcat\">IRC</a><br/>\n");
      out.write("\t\t    &nbsp;\n");
      out.write("                  </td>\n");
      out.write("                </tr>\n");
      out.write("            </table>\n");
      out.write("\t    \n");
      out.write("            <br/>\n");
      out.write("            <table width=\"100%\" border=\"1\" cellspacing=\"0\" cellpadding=\"3\">\n");
      out.write("                <tr>\n");
      out.write("                  <th>Examples</th>\n");
      out.write("                </tr>\n");
      out.write("                <tr>\n");
      out.write("                  <td class=\"menu\">\n");
      out.write("                    <a href=\"examples/servlets/\">Servlets Examples</a><br/>\n");
      out.write("                    <a href=\"examples/jsp/\">JSP Examples</a><br/>\n");
      out.write("                    <a href=\"webdav/\">WebDAV&nbsp;capabilities</a><br/>\n");
      out.write("     \t\t    &nbsp;\n");
      out.write("                  </td>\n");
      out.write("                </tr>\n");
      out.write("            </table>\n");
      out.write("\t    \n");
      out.write("            <br/>\n");
      out.write("            <table width=\"100%\" border=\"1\" cellspacing=\"0\" cellpadding=\"3\">\n");
      out.write("                <tr>\n");
      out.write("\t\t  <th>Miscellaneous</th>\n");
      out.write("                </tr>\n");
      out.write("                <tr>\n");
      out.write("                  <td class=\"menu\">\n");
      out.write("                    <a href=\"http://java.sun.com/products/jsp\">Sun's&nbsp;Java&nbsp;Server&nbsp;Pages&nbsp;Site</a><br/>\n");
      out.write("                    <a href=\"http://java.sun.com/products/servlet\">Sun's&nbsp;Servlet&nbsp;Site</a><br/>\n");
      out.write("    \t\t    &nbsp;\n");
      out.write("                  </td>\n");
      out.write("                </tr>\n");
      out.write("            </table>\n");
      out.write("        </td>\n");
      out.write("\n");
      out.write("        <td style=\"width:20px\">&nbsp;</td>\n");
      out.write("\t\n");
      out.write("        <!-- Body -->\n");
      out.write("        <td align=\"left\" valign=\"top\">\n");
      out.write("          <p id=\"congrats\">If you're seeing this page via a web browser, it means you've setup Tomcat successfully. Congratulations!</p>\n");
      out.write(" \n");
      out.write("          <p>As you may have guessed by now, this is the default Tomcat home page. It can be found on the local filesystem at:</p>\n");
      out.write("          <p class=\"code\">$CATALINA_HOME/webapps/ROOT/index.jsp</p>\n");
      out.write("\t  \n");
      out.write("          <p>where \"$CATALINA_HOME\" is the root of the Tomcat installation directory. If you're seeing this page, and you don't think you should be, then either you're either a user who has arrived at new installation of Tomcat, or you're an administrator who hasn't got his/her setup quite right. Providing the latter is the case, please refer to the <a href=\"docs\">Tomcat Documentation</a> for more detailed setup and administration information than is found in the INSTALL file.</p>\n");
      out.write("\n");
      out.write("            <p><b>NOTE: For security reasons, using the administration webapp\n");
      out.write("            is restricted to users with role \"admin\". The manager webapp\n");
      out.write("            is restricted to users with role \"manager\".</b>\n");
      out.write("            Users are defined in <code>$CATALINA_HOME/conf/tomcat-users.xml</code>.</p>\n");
      out.write("\n");
      out.write("            <p>Included with this release are a host of sample Servlets and JSPs (with associated source code), extensive documentation, and an introductory guide to developing web applications.</p>\n");
      out.write("\n");
      out.write("            <p>Tomcat mailing lists are available at the Tomcat project web site:</p>\n");
      out.write("\n");
      out.write("           <ul>\n");
      out.write("               <li><b><a href=\"mailto:users@tomcat.apache.org\">users@tomcat.apache.org</a></b> for general questions related to configuring and using Tomcat</li>\n");
      out.write("               <li><b><a href=\"mailto:dev@tomcat.apache.org\">dev@tomcat.apache.org</a></b> for developers working on Tomcat</li>\n");
      out.write("           </ul>\n");
      out.write("\n");
      out.write("            <p>Thanks for using Tomcat!</p>\n");
      out.write("\n");
      out.write("            <p id=\"footer\"><img src=\"tomcat-power.gif\" width=\"77\" height=\"80\" alt=\"Powered by Tomcat\"/><br/>\n");
      out.write("\t    &nbsp;\n");
      out.write("\n");
      out.write("\t    Copyright &copy; 1999-2006 Apache Software Foundation<br/>\n");
      out.write("            All Rights Reserved\n");
      out.write("            </p>\n");
      out.write("        </td>\n");
      out.write("\n");
      out.write("    </tr>\n");
      out.write("</table>\n");
      out.write("\n");
      out.write("</body>\n");
      out.write("</html>\n");
    } catch (Throwable t) {
      if (!(t instanceof SkipPageException)){
        out = _jspx_out;
        if (out != null && out.getBufferSize() != 0)
          try { out.clearBuffer(); } catch (java.io.IOException e) {}
        if (_jspx_page_context != null) _jspx_page_context.handlePageException(t);
      }
    } finally {
      _jspxFactory.releasePageContext(_jspx_page_context);
    }
  }
}
