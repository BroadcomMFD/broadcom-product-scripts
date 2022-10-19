package com.broadcom.msd.om.sample.favorites.configuration;

import java.io.Serializable;
import java.util.List;
import java.util.regex.Pattern;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import org.openapitools.client.model.UserUpdateModel.ModeEnum;

/**
 * Model of a favorite configuration entry.
 */
@AllArgsConstructor
@Getter
@Setter
public class Favorite implements Serializable {

  /**
   * Pattern for allowed favorite names.
   *
   * <p>Designed to be usable as file names on any reasonable file system.</p>
   */
  public static final Pattern NAME_PATTERN = Pattern.compile("\\w[ .\\-\\w]*");

  private final int repository;
  private final ModeEnum mode;
  private final String distributionId;
  private final List<String> reports;
  private final int latestVersions;
  private final boolean combine;
  private final boolean pdf;

  // The name of the favorite is transient. It is encoded in the resulting file name rather
  // than serialized into the data.
  private transient String name;
}
