package com.ca.om.webviewer.samples.api.service;

import com.ca.om.webviewer.samples.api.util.ApiConstants;
import com.ca.om.webviewer.samples.api.util.ApiQueryException;
import com.ca.om.webviewer.samples.api.util.RequestUtility;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import org.json.JSONArray;
import org.json.JSONObject;

/**
 * Get a list of repositories.
 */
public class ListRepositories {

  // Max length is 10 characters for Repository id, 100 for Name, 17 for Path, 250 for Description.
  private static String REPOSITORY_LIST_FORMATTER =
      "%-10s|%-100s|%-17s|%-250s" + System.lineSeparator();

  /**
   * List the repositories accessible to user.
   *
   * @param baseUrl Http address and port for the application server.
   * @param sessionToken Session token obtained previously.
   * @return List of each repository id.
   * @throws IOException For any error that occurs while the response is read.
   * @throws ApiQueryException For any unsuccessful response.
   */
  public static List<Integer> listRepository(String baseUrl, String sessionToken)
      throws IOException, ApiQueryException {

    assert baseUrl != null;
    assert sessionToken != null;

    // Compose the address for the GET repository list operation.
    String address = baseUrl + ApiConstants.LIST_REPOSITORY;

    List<Integer> repositoryList = new ArrayList<>();

    // Execute the GET request and process the response based on the returned http status.
    RequestUtility.getListAndProcess(address, sessionToken, result -> {
      // Process successful response.

      // From the result, extract and print the number of repositories.
      // Available properties: repositoryCount and availableRepositoryCount
      int repositoryCount = result.getInt("repositoryCount");
      System.out.println("Total found repository: " + repositoryCount);

      // Return if no repositories are found.
      if (repositoryCount <= 0) {
        return;
      }

      // Extract the repository list.
      JSONArray repositories = result.getJSONArray("repository");

      System.out.println("Displaying list of repositories.");
      System.out.format(REPOSITORY_LIST_FORMATTER, "Repository id", "Name", "Path", "Description");

      for (int i = 0; i < repositories.length(); i++) {
        // Available properties: id, name, description, system, system2, path, product, charset,
        // createdBy, createdDateTime, modifiedBy, modifiedDateTime, reportAccessPolicy
        JSONObject repository = repositories.getJSONObject(i);

        // Print Repository id|Name|Path|Description for each repository
        System.out.format(REPOSITORY_LIST_FORMATTER, repository.get("id"), repository.get("name"),
            repository.get("path"), repository.get("description"));

        // Add repository id to the list.
        repositoryList.add(repository.getInt("id"));
      }
    });

    // Return the list of repository ids.
    return repositoryList;
  }
}
