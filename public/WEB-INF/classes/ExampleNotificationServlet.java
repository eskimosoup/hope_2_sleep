import com.google.checkout.sdk.commands.ApiContext;
import com.google.checkout.sdk.commands.Environment;
import com.google.checkout.sdk.domain.AuthorizationAmountNotification;
import com.google.checkout.sdk.domain.OrderSummary;
import com.google.checkout.sdk.notifications.BaseNotificationDispatcher;
import com.google.checkout.sdk.notifications.Notification;

import java.util.LinkedHashMap;
import java.util.Map;

import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

// custom
import javax.servlet.ServletException;
import java.io.IOException;
import java.io.PrintWriter;

import java.io.*;
import java.net.*;
import javax.net.ssl.*; 

import java.util.regex.*;


public class ExampleNotificationServlet
    extends HttpServlet {
  public static final ApiContext API_CONTEXT =
      new ApiContext(Environment.SANDBOX, "276996054562039", "TeiR8Zzzb0KG1A_ifWGJfA", "GBP");

  public static final Map<String, OrderSummary> ORDERS =
      new LinkedHashMap<String, OrderSummary>();

  @Override
  public void doPost(HttpServletRequest request, HttpServletResponse response) {
    API_CONTEXT.handleNotification(
      new BaseNotificationDispatcher(request, response) {
        @Override
        public void onAllNotifications(OrderSummary orderSummary,
            Notification notification) {
          ORDERS.put(orderSummary.getGoogleOrderNumber(), orderSummary);
        }

        @Override
        public void onAuthorizationAmountNotification(OrderSummary orderSummary,
            AuthorizationAmountNotification notification) {
          System.out.println(
              "Order " + notification.getGoogleOrderNumber()
              + " authorized and ready to ship to:"
              + orderSummary.getBuyerShippingAddress().getContactName());
          System.out.println("Order Details:");
          System.out.println(orderSummary.toString());
              
          // Custom Code
          
          Pattern p = Pattern.compile("<merchant-item-id>(\\d*)</merchant-item-id>");
          Matcher m = p.matcher(orderSummary.toString());
          String data = "status=complete&basket_id=" + m.find();
          try {
            
            // Send the request
            URL url = new URL("http://www.yourproject-11.co.uk/baskets/google_reply");
            URLConnection conn = url.openConnection();
            conn.setDoOutput(true);
            OutputStreamWriter writer = new OutputStreamWriter(conn.getOutputStream());
            
            //write parameters
            writer.write(data);
            writer.flush();
            
            // Get the response
            StringBuffer answer = new StringBuffer();
            BufferedReader reader = new BufferedReader(new InputStreamReader(conn.getInputStream()));
            String line;
            while ((line = reader.readLine()) != null) {
                answer.append(line);
            }
            writer.close();
            reader.close();
            
            //Output the response
            System.out.println(answer.toString());
            System.out.println("Website informed.");
            
        }
        catch (MalformedURLException ex) {
          System.out.println("Error informing website.");
          System.out.println(ex.getMessage());
        }
        catch (IOException ex) {
          System.out.println("Error informing website.");
          System.out.println(ex.getMessage());
        }

          // End Custom Code
        }

        @Override
        protected void rememberSerialNumber(String serialNumber,
            OrderSummary orderSummary, Notification notification) {
          // NOTE: We'll have to remember serial numbers in our database,
          // before using this for real
        }
        
        @Override
        public boolean hasAlreadyHandled(String serialNumber,
            OrderSummary orderSummary, Notification notification) {
          // NOTE: We'll have to look up serial numbers in our database
          // before using this for real
          return false;
        }
      });
  }
}
