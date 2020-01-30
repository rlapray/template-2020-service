package controllers;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.node.JsonNodeFactory;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.google.inject.Inject;
import com.google.inject.Singleton;
import com.typesafe.config.Config;
import com.typesafe.config.ConfigRenderOptions;
import com.typesafe.config.ConfigValue;
import play.Logger;
import play.libs.ws.WSClient;
import play.libs.Json;
import play.mvc.*;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.util.*;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.CompletionStage;

/**
 * This controller contains an action to handle HTTP requests
 * to the application's home page.
 */
@Singleton
public class HomeController extends Controller {

    public class HealcheckData extends LinkedHashMap<String, Object> {
        public HealcheckData() {
            super();
        }
    }


    private final Config config;
    private final WSClient ws;

    @Inject
    public HomeController(final Config config, final WSClient ws)
    {
        this.config = config;
        this.ws = ws;
    }


    public Result yes() {
        return ok("OK !");
    }

    public Result no() {
        return internalServerError("KO !");
    }

    public Result env() {
        System.out.println("env");
        return ok(Json.toJson(System.getenv()).toPrettyString()); }

    public Result healthcheck() {

        HealcheckData root = new HealcheckData();

        HealcheckData env = new HealcheckData();
        env.put("environment", System.getenv("environment"));
        env.put("AWS_REGION", System.getenv("AWS_REGION"));
        env.put("JAVA_VERSION", System.getenv("JAVA_VERSION"));

        HealcheckData build = new HealcheckData();
        Config codebuild = config.getConfig("codebuild");
        for(Map.Entry<String, ConfigValue> entry : codebuild.entrySet()) {
            build.put(entry.getKey(), entry.getValue().render());
        }



        JsonNode codebuildJson = Json.parse(config.getValue("codebuild").render(ConfigRenderOptions.concise()));

        root.put("environment", env);
        root.put("build", Json.fromJson(codebuildJson, HashMap.class));

        return ok(Json.toJson(root).toPrettyString());
    }

    public Result buildInfo() {
        StringBuilder sb = new StringBuilder();
        sb.append("image : " + config.getString("image") + "\n");
        sb.append("commit : " + config.getString("commit") + "\n");
        sb.append("build_id : " + config.getString("build_id") + "\n");
        sb.append("build_region : " + config.getString("build_region") + "\n");
        sb.append("build_image : " + config.getString("build_image") + "\n");
        sb.append("build_event : " + config.getString("build_event") + "\n");
        sb.append("build_trigger : " + config.getString("build_trigger") + "\n");
        sb.append("build_start : " + config.getString("build_start") + "\n");
        return ok(sb.toString());
    }

    public Result db() throws Throwable {
        //CREATE ROLE staging SUPERUSER CREATEDB LOGIN PASSWORD 'stagingpassword';
        //CREATE DATABASE staging OWNER staging;

        String cluster = System.getenv("sql.cluster.url");
        String database = System.getenv("sql.database");
        String user = System.getenv("sql.user");
        String password = System.getenv("sql.password");

        String url = String.format("jdbc:postgresql://%s/%s", cluster, database);

        System.out.println("URL *** " + url);

        System.out.println("user *** " + user);
        System.out.println("password *** " + password);

        Properties props = new Properties();
        props.setProperty("user",user);
        props.setProperty("password",password);
        props.setProperty("ssl","true");
        props.setProperty("sslfactory", "org.postgresql.ssl.DefaultJavaSSLFactory");
        props.setProperty("sslmode", "verify-full");
        Connection conn = DriverManager.getConnection(url, props);
        ResultSet rs = conn.createStatement().executeQuery("select table_name from information_schema.tables");
        StringBuilder sb = new StringBuilder();
        while (rs.next()) {
            sb.append(rs.getString(1));
            sb.append("\n");
        }
        return ok(sb.toString());
    }

    public CompletionStage<Result> metadataContainer() {
        return ws.url(System.getenv("ECS_CONTAINER_METADATA_URI")).get().thenApply(response -> {
            return ok(response.asJson().toPrettyString());
        });
    }

    public CompletionStage<Result> metadataTask() {
        return ws.url(System.getenv("ECS_CONTAINER_METADATA_URI") + "/task").get().thenApply(response -> {
            return ok(response.asJson().toPrettyString());
        });
    }

    public CompletionStage<Result> metadataContainerStats() {
        return ws.url(System.getenv("ECS_CONTAINER_METADATA_URI") + "/stats").get().thenApply(response -> {
            return ok(response.asJson().toPrettyString());
        });
    }

    public CompletionStage<Result> metadataTaskStats() {
        return ws.url(System.getenv("ECS_CONTAINER_METADATA_URI") + "/task/stats").get().thenApply(response -> {
            return ok(response.asJson().toPrettyString());
        });
    }

    public CompletionStage<Result> envoy(String url) {
        return ws.url(url).get().thenApply(response -> {
            StringBuilder sb = new StringBuilder();
            sb.append("statusCode : " + response.getStatus());
            sb.append("\nheaders : " + Json.toJson(response.getHeaders()).toPrettyString());
            sb.append("\nbody : \n " + response.getBody());
            return ok(sb.toString());
        });
    }

}
