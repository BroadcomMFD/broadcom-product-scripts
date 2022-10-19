package com.ca.om.webviewer.samples.api.util;

import static java.net.HttpURLConnection.HTTP_OK;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.function.Consumer;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Utility class for common codes. This utility includes functions for default GET operations, with
 * all pre-processing, to convert responses to json, and to print response messages.
 */
public class RequestUtility {

  private RequestUtility() {
    throw new UnsupportedOperationException();
  }

  /**
   * Read and convert the REST API response to JSON for processing.
   *
   * @param serviceResponse REST API service response.
   * @return Service response in JSON.
   * @throws IOException For any input stream that failed to be read.
   */
  public static JSONObject convertResponseToJson(InputStreamReader serviceResponse)
      throws IOException {
    // Write the output response to the buffer reader.
    try (BufferedReader in = new BufferedReader(serviceResponse)) {
      StringBuilder response = new StringBuilder();
      String line;
      while ((line = in.readLine()) != null) {
        response.append(line);
      }

      // Return the response in JSON.
      return new JSONObject(response.toString());
    }
  }

  /**
   * Print each message from the response message array to standard output.
   *
   * @param messages Response message array.
   */
  public static void printResponseMessages(JSONArray messages) {
    for (int i = 0; i < messages.length(); i++) {
      // Available properties: shortText, longText.
      if (messages.getJSONObject(i).has("longText")) {
        System.out.println("Response Message: " + messages.getJSONObject(i).get("longText"));
      } else {
        System.out.println("Response Message: " + messages.getJSONObject(i).get("shortText"));
      }
    }
  }

  /**
   * Set up an http connection for the requested address, and process the response based on the http
   * status. For a Successful response, extract the JSON text, call the callBack function, and print
   * each message. For any error, throw an ApiQueryException.
   *
   * @param address REST API request address.
   * @param sessionToken Session token to authenticate.
   * @param successfulResponseProcessor Consumer object for the Successful response call-back.
   * @throws IOException For any error that occurs while the response is read.
   * @throws ApiQueryException For any unsuccessful response.
   */
  public static void getListAndProcess(String address, String sessionToken,
      Consumer<JSONObject> successfulResponseProcessor) throws IOException, ApiQueryException {

    // Set up the http connection for the requested address.
    URL url = new URL(address);
    HttpURLConnection connection = (HttpURLConnection) url.openConnection();

    // Set the request type to GET.
    connection.setRequestMethod("GET");

    // Pass the session token to authenticate.
    connection.setRequestProperty("guid", sessionToken);

    // Execute the request and get the response code.
    int httpStatus = connection.getResponseCode();

    // Throw exception if http response status is not successful.
    if (httpStatus != HTTP_OK) {
      // For any unsuccessful response, throw a new REST API Query exception.
      throw new ApiQueryException(connection);
    }

    // Read and convert the Successful response to JSON for processing.
    final JSONObject jsonObject = convertResponseToJson(
        new InputStreamReader(connection.getInputStream()));

    if (jsonObject.has("result")) {
      // Extract the JSON text from the response.
      JSONObject result = jsonObject.getJSONObject("result");

      // Call the callBack function.
      successfulResponseProcessor.accept(result);
    }

    // Check whether the response contains a message.
    if (jsonObject.has("message")) {
      // Extract and print each REST API response message.
      printResponseMessages(jsonObject.getJSONArray("message"));
    }

    // Terminate the connection and release each resource.
    connection.disconnect();
  }
}
