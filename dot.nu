#!/usr/bin/env nu
def main [] {}
# Runs all CI tasks
def "main run ci" [
    tag: string # The tag of the image (e.g., 0.0.1)!
    manifest = "apps/silly-demo.yaml" # The path to the manifest file
    --run_tests = true # Whether to run tests
    --build_images = true # Whether to build images
] {
    if $run_tests {
        main run tests --language go
    }
    if $build_images {
        main build image $tag
    }
    main update claim $tag $manifest
}
# Runs tests
def "main run tests" [
    --language = "go" # The language of the project (e.g., go)
] {
    if $language == "go" {
        go test -v $"(pwd)/..."
    }
}
# Builds and (optionally) pushes container images
def "main build image" [
    tag: string   # The tag of the image (e.g., 0.0.1)
    --push = true # Whether to push the image to the registry
] {
    docker image build --tag $"ghcr.io/vfarcic/cncf-demo-app:latest" .
    docker image tag $"ghcr.io/vfarcic/cncf-demo-app:latest" $"ghcr.io/vfarcic/cncf-demo-app:($tag)"
    if $push {
        docker image push $"ghcr.io/vfarcic/cncf-demo-app:latest"
        docker image push $"ghcr.io/vfarcic/cncf-demo-app:($tag)"
    }
}
# Updates the claim
def "main update claim" [
    tag: string # The tag of the image (e.g., 0.0.1)
    path = "apps/silly-demo.yaml" # The path to the claim file
] {
    open $path | upsert spec.parameters.tag $tag | save $path --force
}