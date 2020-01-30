package controllers;


import com.google.inject.Inject;
import com.google.inject.Provider;
import com.google.inject.Singleton;
import com.typesafe.config.Config;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import play.Environment;
import play.api.OptionalSourceMapper;
import play.api.UsefulException;
import play.api.routing.Router;
import play.http.DefaultHttpErrorHandler;
import play.libs.Json;
import play.mvc.Http;
import play.mvc.Result;
import play.mvc.Results;

import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;

@Singleton
public class ErrorHandler extends DefaultHttpErrorHandler {

    private final Logger logger = LoggerFactory.getLogger(this.getClass());

    @Inject
    public ErrorHandler(
            Config config,
            Environment environment,
            OptionalSourceMapper sourceMapper,
            Provider<Router> routes) {
        super(config, environment, sourceMapper, routes);
    }

    @Override
    public CompletionStage<Result> onClientError(
            Http.RequestHeader request, int statusCode, String message) {
        logger.error("{}  : {} from {} | headers => {}", statusCode, request.path(), request.remoteAddress(), Json.toJson(request.getHeaders().asMap()).toPrettyString());
        return super.onClientError(request, statusCode, message);
    }

    public CompletionStage<Result> onServerError(Http.RequestHeader request, Throwable exception) {
        logger.error("500  : {} from {} | headers => {}", request.path(), request.remoteAddress(), Json.toJson(request.getHeaders().asMap()).toPrettyString());
        return super.onServerError(request, exception);
    }
}