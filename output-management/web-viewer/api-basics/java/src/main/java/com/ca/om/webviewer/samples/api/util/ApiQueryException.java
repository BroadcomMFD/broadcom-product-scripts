package com.ca.om.webviewer.samples.api.util;

import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Exception class for an unsuccessful REST API operation.
 */
public class ApiQueryException extends Exception {

  private final transient HttpURLConnection httpURLConnection;
  private final int httpStatus;
  private final String applicationErrorMessages;

  public ApiQueryException(HttpURLConnection httpURLConnection) throws IOException {
    this.httpURLConnection = httpURLConnection;
    this.httpStatus = httpURLConnection.getResponseCode();
    this.applicationErrorMessages = extractErrorMessages();
  }

  public int getHttpStatus() {
    return httpStatus;
  }

  public String getApplicationErrorMessages() {
    return applicationErrorMessages;
  }

  /**
   * From the error response, extract and return each message in a single stream. Handles any
   * unknown error response or error response with Content-Type not json separately.
   *
   * @return Each message from REST API error response or generic message for unknown errors.
   * @throws IOException For any exception that occurs while the response is read.
   */
  private String extractErrorMessages() throws IOException {
    // All the handled response status returns a json response.
    if (!httpURLConnection.getHeaderField("Content-Type").equals("application/json")) {
      return "An unknown error has occurred.";
    }

    final JSONObject jsonObject = RequestUtility
        .convertResponseToJson(new InputStreamReader(httpURLConnection.getErrorStream()));

    // Process http response with no error messages.
    if (!jsonObject.has("message")) {
      return "No error message was generated.";
    }

    StringBuilder errorMessages = new StringBuilder();
    JSONArray messages = jsonObject.getJSONArray("message");
    for (int i = 0; i < messages.length(); i++) {
      if (messages.getJSONObject(i).has("longText")) {
        errorMessages.append(messages.getJSONObject(i).getString("longText"));
      } else {
        errorMessages.append(messages.getJSONObject(i).getString("shortText"));
      }
    }
    return errorMessages.toString();
  }
}
