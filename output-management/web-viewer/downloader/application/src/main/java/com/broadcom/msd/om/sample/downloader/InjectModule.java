package com.broadcom.msd.om.sample.downloader;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.inject.*;

/**
 * Default injection module definition.
 */
public class InjectModule extends AbstractModule {
  @Provides
  @Singleton
  static Gson provideGson() {
    return new GsonBuilder()
        .serializeNulls()
        .setPrettyPrinting()
        .create();
  }
}
