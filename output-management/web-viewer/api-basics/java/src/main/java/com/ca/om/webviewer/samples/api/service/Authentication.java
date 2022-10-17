package com.ca.om.webviewer.samples.api.service;

import static java.net.HttpURLConnection.HTTP_OK;

import com.ca.om.webviewer.samples.api.util.ApiConstants;
import com.ca.om.webviewer.samples.api.util.ApiQueryException;
import com.ca.om.webviewer.samples.api.util.RequestUtility;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Base64;
import org.json.JSONObject;

/**
 * Log in and log out of the application.
 */
public class Authentication {

  /**
   * Authenticate with a username and password.
   *
   * @param baseUrl Http address and port for the application server.
   * @param username User id to authenticate.
   * @param password User password to authenticate.
   * @return Generated session token (guid) or null.
   * @throws IOException For any error that occurs while the response is read.
   * @throws ApiQueryException For any unsuccessful response.
   */
  public static String loginWithUserName(String baseUrl, String username, String password)
      throws ApiQueryException, IOException {

    assert baseUrl != null;
    assert username != null;
    assert password != null;

    String address = baseUrl + ApiConstants.LOGIN;
    String sessionToken;

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

    // Retrieve the session token (guid) from the response header.
    sessionToken = connection.getHeaderField("guid");

    // Each successful Login request generates a session token.
    if (sessionToken != null) {
      System.out.println("Login Successful");
      System.out.println("Generated sessionToken: " + sessionToken);
    }

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

    return sessionToken;
  }

  /**
   * Log out - Invalidate the session token.
   *
   * @param baseUrl Http address and port for the application server.
   * @param sessionToken Session token to be invalidated.
   * @throws IOException For any error that occurred while the response is read.
   * @throws ApiQueryException For any unsuccessful response.
   */
  public static void logout(String baseUrl, String sessionToken)
      throws IOException, ApiQueryException {

    assert baseUrl != null;
    assert sessionToken != null;

    String address = baseUrl + ApiConstants.LOGOUT;

    // Set up the http connection.
    URL url = new URL(address);
    HttpURLConnection connection = (HttpURLConnection) url.openConnection();

    // POST is the request type for the Logout operation.
    connection.setRequestMethod("POST");

    // Pass the session token (guid) to be invalidated.
    connection.setRequestProperty("guid", sessionToken);

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
