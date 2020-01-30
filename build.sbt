name := """template-2020-service"""
organization := "fr.rlapray"

version := "0.0-SNAPSHOT"

lazy val root = (project in file(".")).enablePlugins(PlayJava)

scalaVersion := "2.13.1"

libraryDependencies += guice
libraryDependencies += javaJdbc
libraryDependencies += javaWs
libraryDependencies += "org.postgresql" % "postgresql" % "42.2.8"

sources in (Compile, doc) := Seq.empty
publishArtifact in (Compile, packageDoc) := false
