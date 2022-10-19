package com.broadcom.msd.om.sample.favorites.configuration;

import com.google.gson.Gson;
import com.google.inject.Inject;
import com.google.inject.Singleton;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.PathMatcher;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import lombok.Getter;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;

/**
 * Provides access to the file-based application configuration.
 *
 * <p>All the persisted application configuration is stored as JSON files in the
 * {@link #CONFIGURATION_DIRECTORY} directory under the user home directory.</p>
 *
 * <p>All the configuration files are designed to be human-readable and transferable between users
 * and hosts.</p>
 */
@Slf4j
@Getter
@Singleton
public class ApplicationConfiguration {
  private static final String CONFIGURATION_DIRECTORY = ".web-viewer";
  private static final PathMatcher JSON_MATCHER =
      FileSystems.getDefault().getPathMatcher("glob:**.json");

  final Path root;
  final Path url;
  final Path username;
  final Path favorites;
  private final Gson gson;

  @Inject
  public ApplicationConfiguration(Gson gson) throws IOException {
    this.gson = gson;

    root = Path.of(FileUtils.getUserDirectoryPath(), CONFIGURATION_DIRECTORY);
    url = root.resolve("endpoint.json");
    username = root.resolve("username.json");
    favorites = root.resolve("favorites");

    for (Path dir : Arrays.asList(root, favorites)) {
      if (!Files.exists(dir)) {
        Files.createDirectories(dir);
      }
    }
  }

  public String getUrl() {
    return load(url, String.class, null);
  }

  public void setUrl(String value) {
    try {
      save(url, value);
    } catch (IOException e) {
      log.error("Failed to save endpoint URL.", e);
    }
  }

  public String getUsername() {
    return load(username, String.class, System.getProperty("user.name"));
  }

  public void setUsername(String value) {
    try {
      save(username, value);
    } catch (IOException e) {
      log.error("Failed to save username.", e);
    }
}

  /**
   * Returns list of names for defined favorites.
   *
   * @return List of favorite names.
   */
  public List<String> listFavoriteNames() {
    try (Stream<Path> files = Files.list(favorites)) {
      return files
          .filter(Files::isRegularFile)
          .filter(JSON_MATCHER::matches)
          .map(this::loadFavorite)
          .filter(Objects::nonNull)
          .map(Favorite::getName)
          .collect(Collectors.toList());
    } catch (IOException e) {
      log.error("Failed to load favorites information from disk.", e);
      return Collections.emptyList();
    }
  }

  /**
   * Loads a favorite.
   *
   * @param name Name of favorite
   * @return Favorite.
   */
  public Favorite loadFavorite(String name) {
    return loadFavorite(getFavoritePath(name));
  }

  /**
   * Saves a favorite.
   *
   * @param favorite Favorite
   * @param overwrite Whether an existing favorite should be overwritten. A skipped overwrite is
   * silently ignored.
   */
  public void saveFavorite(Favorite favorite, boolean overwrite) {
    final Path path = getFavoritePath(favorite.getName());

    if (overwrite || !Files.isRegularFile(path)) {
      try {
        save(path, favorite);
      } catch (IOException e) {
        log.error("Failed to save favorite.", e);
      }
    }
  }

  /**
   * Deletes a favorite.
   *
   * @param name Name of favorite.
   */
  public void deleteFavorite(String name) {
    try {
      Files.deleteIfExists(getFavoritePath(name));
    } catch (IOException e) {
      log.error("Failed to delete favorite.", e);
    }
  }

  private Favorite loadFavorite(Path path) {
    final Favorite favorite = load(path, Favorite.class, null);
    if (favorite == null) {
      return null;
    }

    favorite.setName(FilenameUtils.getBaseName(path.toString()));

    return favorite;
  }

  private Path getFavoritePath(String name) {
    return favorites.resolve(String.format("%s.json", name));
  }

  /**
   * Low-level save (serialization) operation.
   *
   * <p>Any existing data in the target file will be lost.</p>
   *
   * @param path Path to target file.
   * @param data Data to serialize.
   * @param <T> Data type.
   */
  private <T> void save(Path path, T data) throws IOException {
    try (FileWriter fileWriter = new FileWriter(path.toFile())) {
      gson.toJson(data, fileWriter);
    }
  }

  /**
   * Low-level load (deserialization) operation.
   *
   * @param path Path to target file.
   * @param clazz Class of the target data type.
   * @param defaultValue Default value returned existing configuration is not available.
   * @param <T> Data type.
   */
  private <T> T load(Path path, Class<T> clazz, T defaultValue) {
    try (FileReader fileReader = new FileReader(path.toFile())) {
      return gson.fromJson(fileReader, clazz);
    } catch (IOException e) {
      return defaultValue;
    }
  }
}
