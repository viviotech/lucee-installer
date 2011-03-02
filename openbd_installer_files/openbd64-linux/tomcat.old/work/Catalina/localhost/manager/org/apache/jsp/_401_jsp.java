package org.apache.jsp;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;

public final class _401_jsp extends org.apache.jasper.runtime.HttpJspBase
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
    HttpSession session = null;
    ServletContext application = null;
    ServletConfig config = null;
    JspWriter out = null;
    Object page = this;
    JspWriter _jspx_out = null;
    PageContext _jspx_page_context = null;


    try {
      response.setContentType("text/html");
      pageContext = _jspxFactory.getPageContext(this, request, response,
      			null, true, 8192, true);
      _jspx_page_context = pageContext;
      application = pageContext.getServletContext();
      config = pageContext.getServletConfig();
      session = pageContext.getSession();
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

  response.setHeader("WWW-Authenticate", "Basic realm=\"Tomcat Manager Application\"");

      out.write("\n");
      out.write("<html>\n");
      out.write(" <head>\n");
      out.write("  <title>401 Unauthorized</title>\n");
      out.write("  <style>\n");
      out.write("    <!--\n");
      out.write("    BODY {font-family:Tahoma,Arial,sans-serif;color:black;background-color:white;font-size:12px;}\n");
      out.write("    H1 {font-family:Tahoma,Arial,sans-serif;color:white;background-color:#525D76;font-size:22px;}\n");
      out.write("    PRE, TT {border: 1px dotted #525D76}\n");
      out.write("    A {color : black;}A.name {color : black;}\n");
      out.write("    -->\n");
      out.write("  </style>\n");
      out.write(" </head>\n");
      out.write(" <body>\n");
      out.write("   <h1>401 Unauthorized</h1>\n");
      out.write("   <p>\n");
      out.write("    You are not authorized to view this page. If you have not changed\n");
      out.write("    any configuration files, please examine the file\n");
      out.write("    <tt>conf/tomcat-users.xml</tt> in your installation. That\n");
      out.write("    file will contain the credentials to let you use this webapp.\n");
      out.write("   </p>\n");
      out.write("   <p>\n");
      out.write("    You will need to add <tt>manager</tt> role to the config file listed above.\n");
      out.write("    For example:\n");
      out.write("<pre>\n");
      out.write("&lt;role rolename=\"manager\"/&gt;\n");
      out.write("&lt;user username=\"tomcat\" password=\"s3cret\" roles=\"manager\"/&gt;\n");
      out.write("</pre>\n");
      out.write("   </p>\n");
      out.write("   <p>\n");
      out.write("    For more information - please see the\n");
      out.write("    <a href=\"/docs/manager-howto.html\">Manager App HOW-TO</a>.\n");
      out.write("   </p>\n");
      out.write(" </body>\n");
      out.write("\n");
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
