package com.broadcom.msd.om.sample.downloader.configuration;

import com.google.inject.Singleton;
import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
import org.apache.commons.io.FileUtils;

@Singleton
public class ApplicationConfiguration {

  private static final Path root = Path.of(FileUtils.getUserDirectoryPath(), ".web-viewer");

  public static final ConfigurationOption<String> ENDPOINT = new ConfigurationOption<>(
      "Endpoint URL", root.resolve("endpoint.json"), String.class,
      () -> null);

  public static final ConfigurationOption<String> USERNAME = new ConfigurationOption<>(
      "Username", root.resolve("username.json"), String.class,
      () -> System.getProperty("user.name"));

  public static final ConfigurationOption<File> DOWNLOAD_DIRECTORY = new ConfigurationOption<>(
      "Download directory", root.resolve("downloadDirectory.json"), File.class,
      () -> {
        final File home = Paths.get(System.getProperty("user.home")).toFile();
        if (!home.isDirectory()) {
          return null;
        }

        File directory;
        if (System.getProperty("os.name").contains("Windows")) {
          directory = new File(home, "Downloads");
        } else {
          directory = home;
        }

        if (directory.canWrite()) {
          return directory;
        } else {
          return null;
        }
      });
}
