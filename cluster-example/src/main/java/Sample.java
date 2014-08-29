package src.main.java;

import java.io.*;
import javax.servlet.*;
import javax.servlet.http.*;
import java.util.*;

import org.apache.log4j.Logger;

public class Sample extends HttpServlet {

  public static final Logger LOG = Logger.getLogger(Sample.class);
  private String urlpath = "";

  public void init(ServletConfig config) throws ServletException
  {
    super.init(config);
  }

  public String getServletInfo() {
    return "Sample Servlet";
  }

  public void processRequest(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException { 

    response.setContentType("text/html");
    HttpSession session = request.getSession();

    String SessionID = request.getSession().getId(); 

    LOG.debug("SessionID: " + SessionID);

    PrintWriter out = response.getWriter();

    out.println("<html>\n<head>\n<title>Example Cluster Servlet</title>\n</head>");
    out.println("<body>");

    out.println("<h1>Example Clustered Servelet</h1><br/>");
    out.println("Session ID: <b>" + SessionID + "</b> | Serverd By: <b>" + System.getenv("OPENSHIFT_GEAR_UUID") + "</b><br/>"); 

    SampleObj sample = getSessionObj(session); 

    boolean update = false; 
    Enumeration paramNames = request.getParameterNames();
    while(paramNames.hasMoreElements()) {
        String paramName = (String)paramNames.nextElement();
        String parameter = request.getParameterValues(paramName)[0];
        
        LOG.debug("#############################");
        LOG.debug("## Name: " + paramName + " ##");
        LOG.debug("## Value: " + parameter + " ##");

        if (paramName.equals("objName")) {
            sample.setName(parameter);
            LOG.debug("## Update OBJ Name: " +  parameter);
            update = true; 
        } else if (paramName.equals("objValue")) {
            sample.setValue(Integer.parseInt(parameter));
            LOG.debug("## Update OBJ Value: " +  parameter);
            update = true;
        }
        LOG.debug("#############################");
    }

    if (!update) {
        sample.addValue();
    }

    String urlpath = request.getContextPath() + request.getRequestURI().substring(request.getContextPath().length()); 

    /* For this example I don't need the ability to update the object. 
    out.println("URL Path: " + urlpath);

    out.println("<FORM ACTION=\"" + urlpath + "\" METHOD=\"POS\">"); 
    out.println("Object Name: <input type=\"text\" name=\"objName\" value=\"" + sample.getName() + "\"><br/>");
    out.println("Object Value: <input type=\"text\" name=\"objValue\" value=\"" + sample.getValue() + "\"><br/>");
    out.println("<input type=\"submit\" value=\"Update Object\">");
    out.println("</FORM>");
    */
    out.println("</body>");
    out.println("</html>");

    out.close();
  }

  private SampleObj getSessionObj(HttpSession session) { 
    SampleObj sample = (SampleObj)session.getAttribute("SampleAttribute");
    if (sample == null) {
        sample = new SampleObj();
        session.setAttribute("SampleAttribute", sample);
    }
    return sample; 
  }

  public void doGet(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    LOG.info("**" + this.getServletInfo() + " GET Called ** ");
    processRequest(request, response);
  }

  public void doPost(HttpServletRequest request, HttpServletResponse response)
      throws ServletException, IOException {
    LOG.info("**" + this.getServletInfo() + " POST Called ** ");
    processRequest(request, response);
  }
}
