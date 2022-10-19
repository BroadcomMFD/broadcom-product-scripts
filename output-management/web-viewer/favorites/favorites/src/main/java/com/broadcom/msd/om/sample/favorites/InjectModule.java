package com.broadcom.msd.om.sample.favorites;

import com.broadcom.msd.om.sample.favorites.configuration.ApplicationConfiguration;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.inject.AbstractModule;
import com.google.inject.Provides;
import com.google.inject.Singleton;

/**
 * Default injection module definition.
 */
public class InjectModule extends AbstractModule {
  @Override
  protected void configure() {
    bind(ApplicationConfiguration.class);
  }

  @Provides
  @Singleton
  static Gson provideGson() {
    return new GsonBuilder()
        .serializeNulls()
        .setPrettyPrinting()
        .create();
  }
}
