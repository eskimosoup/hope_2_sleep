import com.google.checkout.sdk.commands.ApiContext;
import com.google.checkout.sdk.commands.Environment;
import com.google.checkout.sdk.domain.CheckoutRedirect;

public class PostCart {
  public static ApiContext API_CONTEXT = new ApiContext(
         Environment.SANDBOX, "276996054562039", "TeiR8Zzzb0KG1A_ifWGJfA", "GBP");

  public static void main(String[] args) {
    CheckoutRedirect checkoutRedirect = API_CONTEXT.cartPoster().makeCart()
        .addItem("Baseball", "White baseball", 5.99, 2)
        .addItem("Baseball Glove", "XL Baseball Glove", 30.00, 1)
        .buildAndPost();
    System.out.println(
        "Buyer should be redirected to: " + checkoutRedirect.getRedirectUrl());
  }
}
