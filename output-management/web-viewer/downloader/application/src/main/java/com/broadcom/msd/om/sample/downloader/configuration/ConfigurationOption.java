package com.broadcom.msd.om.sample.downloader.configuration;

import com.google.gson.*;
import java.io.*;
import java.lang.reflect.Type;
import java.nio.file.Path;
import java.util.function.Supplier;
import lombok.extern.slf4j.Slf4j;

@Slf4j
public class ConfigurationOption<T> {

  private static final Gson gson = new GsonBuilder()
      .serializeNulls()
      .setPrettyPrinting()
      .registerTypeAdapter(File.class, new FileSerializer())
      .create();

  private final String label;
  private final Path path;
  private final Class<T> clazz;
  private final Supplier<T> defaultSupplier;

  public ConfigurationOption(String label, Path path, Class<T> clazz, Supplier<T> defaultSupplier) {
    this.label = label;
    this.path = path;
    this.clazz = clazz;
    this.defaultSupplier = defaultSupplier;
  }

  public T get() {
    return load(path, clazz);
  }

  public void set(T value) {
    try {
      save(path, value);
    } catch (IOException e) {
      log.error(String.format("Failed to save %s.", label), e);
    }
  }

  public void reset() {
    set(defaultSupplier.get());
  }

  /**
   * Low-level save (serialization) operation.
   *
   * <p>Any existing data in the target file will be lost.</p>
   *
   * @param path Path to target file.
   * @param data Data to serialize.
   */
  private void save(Path path, T data) throws IOException {
    try (FileWriter fileWriter = new FileWriter(path.toFile())) {
      gson.toJson(data, fileWriter);
    }
  }

  /**
   * Low-level load (deserialization) operation.
   *
   * @param path Path to target file.
   * @param clazz Class of the target data type.
   */
  private T load(Path path, Class<T> clazz) {
    try (FileReader fileReader = new FileReader(path.toFile())) {
      return gson.fromJson(fileReader, clazz);
    } catch (JsonParseException | IOException e) {
      return defaultSupplier.get();
    }
  }
}

class FileSerializer implements JsonSerializer<File>, JsonDeserializer<File> {

  @Override
  public File deserialize(JsonElement json, Type typeOfT, JsonDeserializationContext context)
      throws JsonParseException {
    return new File(json.getAsString());
  }

  @Override
  public JsonElement serialize(File src, Type typeOfSrc, JsonSerializationContext context) {
    return new JsonPrimitive(src.getPath());
  }
}
