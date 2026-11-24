package com.ca.om.webviewer.samples.api.service;

import static java.net.HttpURLConnection.HTTP_OK;

import com.ca.om.webviewer.samples.api.util.ApiConstants;
import com.ca.om.webviewer.samples.api.util.ApiQueryException;
import com.ca.om.webviewer.samples.api.util.RequestUtility;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.CookieHandler;
import java.net.CookieManager;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Base64;
import org.json.JSONObject;

/**
 * Log in and log out of the application.
 * <p>
 * The session is carried by an HttpOnly cookie. A default {@link CookieHandler} makes every
 * {@link HttpURLConnection} in this process store the cookie from the login response and resend it
 * automatically on subsequent requests, for the duration of the process lifetime.
 */
public class Authentication {

  static {
    CookieHandler.setDefault(new CookieManager());
  }

  /**
   * Authenticate with a username and password.
   *
   * @param baseUrl HTTPS address and port for the application server.
   * @param username User id to authenticate.
   * @param password User password to authenticate.
   * @throws IOException For any error that occurs while the response is read.
   * @throws ApiQueryException For any unsuccessful response.
   */
  public static void loginWithUserName(String baseUrl, String username, String password)
      throws ApiQueryException, IOException {

    assert baseUrl != null;
    assert username != null;
    assert password != null;

    String address = baseUrl + ApiConstants.LOGIN;

    // Set up the http connection.
    URL url = new URL(address);
    HttpURLConnection connection = (HttpURLConnection) url.openConnection();

    // POST is the request type for the Login operation.
    connection.setRequestMethod("POST");

    // The Login operation uses the http basic authentication scheme.
    connection.setRequestProperty("Authorization",
        "Basic " + Base64.getEncoder().encodeToString((username + ":" + password).getBytes()));

    // Execute the request and get the response code.
    int httpStatus = connection.getResponseCode();

    // Throw exception if http response status is not successful.
    if (httpStatus != HTTP_OK) {
      // For any unsuccessful response, throw a new REST API Query exception.
      throw new ApiQueryException(connection);
    }

    System.out.println("Login Successful");

    // Read the Successful response body and convert it to JSON for processing.
    final JSONObject jsonObject = RequestUtility
        .convertResponseToJson(new InputStreamReader(connection.getInputStream()));

    // Check whether the response has any messages.
    if (jsonObject.has("message")) {
      // Extract and print each REST API response message.
      RequestUtility.printResponseMessages(jsonObject.getJSONArray("message"));
    }

    // Terminate the connection and release each resource.
    connection.disconnect();
  }

  /**
   * Log out - Invalidate the session.
   *
   * @param baseUrl HTTPS address and port for the application server.
   * @throws IOException For any error that occurred while the response is read.
   * @throws ApiQueryException For any unsuccessful response.
   */
  public static void logout(String baseUrl)
      throws IOException, ApiQueryException {

    assert baseUrl != null;

    String address = baseUrl + ApiConstants.LOGOUT;

    // Set up the http connection.
    URL url = new URL(address);
    HttpURLConnection connection = (HttpURLConnection) url.openConnection();

    // POST is the request type for the Logout operation.
    connection.setRequestMethod("POST");

    // The session cookie is attached automatically by the default CookieHandler.

    // Execute the request and get the response code.
    int httpStatus = connection.getResponseCode();

    // Throw exception if http response status is not successful.
    if (httpStatus != HTTP_OK) {
      // For any unsuccessful response, throw a new REST API Query exception.
      throw new ApiQueryException(connection);
    }

    // The Logout response does not have a response body, and requires no processing.
    System.out.println("Logout Successful.");

    // Terminate the connection and release each resource.
    connection.disconnect();
  }
}
