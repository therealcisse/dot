import sbt._
import Keys._

sys.env.get("IVY_LOCAL_REPO").toSeq.flatMap { path =>
  val repo =
    Resolver.file(
      "local-repo-ivy",
      file(path)
    )(Resolver.ivyStylePatterns)

  Seq(
    ThisBuild / resolvers := {
      repo +: (ThisBuild / resolvers).value
    },

    ThisBuild / publishTo := Some(repo),

    ThisBuild / publishMavenStyle := false
  )
}
