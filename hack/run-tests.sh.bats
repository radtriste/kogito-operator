#!/usr/bin/env bats

function go() { 
    echo '' 
}

function oc() { 
    echo ''
}

export -f go
export -f oc

@test "invoke run-tests with dry_run" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.dry_run" ]]
}

@test "invoke run-tests unknown option" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh something
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "Unknown arguments: something" ]
}

# tests configuration

@test "invoke run-tests with test_main_dir" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --test_main_dir ${BATS_TEST_DIRNAME}/../test/scripts/examples --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ " ${BATS_TEST_DIRNAME}/../test/scripts/examples" ]]
}

@test "invoke run-tests with test_main_dir missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --test_main_dir --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ " ${BATS_TEST_DIRNAME}/../test" ]]
}

@test "invoke run-tests with test_main_dir empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --test_main_dir "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ " ${BATS_TEST_DIRNAME}/../test" ]]
}

@test "invoke run-tests with feature" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --feature ${BATS_TEST_DIRNAME}/../test/features --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ " ${BATS_TEST_DIRNAME}/../test/features" ]]
}

@test "invoke run-tests with feature missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --feature --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *" features"* ]]
}

@test "invoke run-tests with feature empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --feature "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *" features"* ]]
}

@test "invoke run-tests with tags" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --tags hello --dry_run 
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--godog.tags=\"hello\"" ]]
}

@test "invoke run-tests with tags multiple values" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --tags "hello and bonjour" --dry_run 
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--godog.tags=\"hello and bonjour\"" ]]
}

@test "invoke run-tests with tags missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --tags --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--godog.tags=\"\"" ]]
}

@test "invoke run-tests with tags empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --tags "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--godog.tags=\"\"" ]]
}

@test "invoke run-tests with concurrent" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --concurrent 3 --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--godog.concurrency=3" ]]
}

@test "invoke run-tests with concurrent missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --concurrent --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--godog.concurrency"* ]]
}

@test "invoke run-tests with concurrent empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --concurrent "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--godog.concurrency"* ]]
}

@test "invoke run-tests with timeout" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --timeout 120 --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "-timeout \"120m\"" ]]
}

@test "invoke run-tests with timeout missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --timeout --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "-timeout \"240m\"" ]]
}

@test "invoke run-tests with timeout empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --timeout "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "-timeout \"240m\"" ]]
}

@test "invoke run-tests with debug" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --debug --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "DEBUG=true go test"* ]]

}

@test "invoke run-tests without debug" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "DEBUG=false go test"* ]]
}

@test "invoke run-tests with smoke" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --smoke --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.smoke" ]]
}

@test "invoke run-tests without smoke" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.smoke"* ]]
}

@test "invoke run-tests with performance" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --performance --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.performance" ]]
}

@test "invoke run-tests without performance" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.performance"* ]]
}

@test "invoke run-tests with load_factor" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --load_factor 3 --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.load_factor=3" ]]
}

@test "invoke run-tests with load_factor missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --load_factor --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.load_factor"* ]]
}

@test "invoke run-tests with load_factor empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --load_factor "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.load_factor"* ]]
}

@test "invoke run-tests with local_execution" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --local_execution --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.local_execution" ]]
}

@test "invoke run-tests without local_execution" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.local_execution"* ]]
}

@test "invoke run-tests with ci" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --ci jenkins --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.ci=jenkins" ]]
}

@test "invoke run-tests with ci missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --ci --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.ci"* ]]
}

@test "invoke run-tests with ci empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --ci "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.ci"* ]]
}

@test "invoke run-tests with cr_deployment_only" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --cr_deployment_only --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.cr_deployment_only" ]]
}

@test "invoke run-tests without cr_deployment_only" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.cr_deployment_only"* ]]
}

@test "invoke run-tests with load_default_config" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --load_default_config --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "Load default test config" ]]
}

@test "invoke run-tests without load_default_config" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"Load default test config"* ]]
}

@test "invoke run-tests with container_engine" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --container_engine podman --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.container_engine=podman" ]]
}

@test "invoke run-tests with container_engine missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --container_engine --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.container_engine"* ]]
}

@test "invoke run-tests with container_engine empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --container_engine "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.container_engine"* ]]
}

@test "invoke run-tests with domain_suffix" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --domain_suffix suffix --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.domain_suffix=suffix" ]]
}

@test "invoke run-tests with domain_suffix missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --domain_suffix --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.domain_suffix"* ]]
}

@test "invoke run-tests with domain_suffix empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --domain_suffix "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.domain_suffix"* ]]
}

@test "invoke run-tests with image_cache_mode" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --image_cache_mode always --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.image_cache_mode=always" ]]
}

@test "invoke run-tests with image_cache_mode missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --image_cache_mode --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.image_cache_mode"* ]]
}

@test "invoke run-tests with image_cache_mode empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --image_cache_mode "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.image_cache_mode"* ]]
}

@test "invoke run-tests with http_retry_nb" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --http_retry_nb 3 --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.http_retry_nb=3" ]]
}

@test "invoke run-tests with http_retry_nb missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --http_retry_nb --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.http_retry_nb"* ]]
}

@test "invoke run-tests with http_retry_nb empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --http_retry_nb "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.http_retry_nb"* ]]
}

@test "invoke run-tests with olm_namespace" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --olm_namespace olm --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.olm_namespace=olm" ]]
}

@test "invoke run-tests with olm_namespace missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --olm_namespace --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.olm_namespace"* ]]
}

@test "invoke run-tests with olm_namespace empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --olm_namespace "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.olm_namespace"* ]]
}

# operator information

@test "invoke run-tests with operator_image_tag" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_image_tag image --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.operator_image_tag=image" ]]
}

@test "invoke run-tests with operator_image_tag missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_image_tag --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.operator_image_tag"* ]]
}

@test "invoke run-tests with operator_image_tag empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_image_tag "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.operator_image_tag"* ]]
}

@test "invoke run-tests with operator_namespaced" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_namespaced --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.operator_namespaced" ]]
}

@test "invoke run-tests without operator_namespaced" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.operator_namespaced"* ]]
}

@test "invoke run-tests with operator_installation_source" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_installation_source olm --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.operator_installation_source=olm" ]]
}

@test "invoke run-tests with operator_installation_source missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_installation_source --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.operator_installation_source"* ]]
}

@test "invoke run-tests with operator_installation_source empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_installation_source "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.operator_installation_source"* ]]
}

@test "invoke run-tests with operator_catalog_image" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_catalog_image catalog-image --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.operator_catalog_image=catalog-image" ]]
}

@test "invoke run-tests with operator_catalog_image missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_catalog_image --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.operator_catalog_image"* ]]
}

@test "invoke run-tests with operator_catalog_image empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_catalog_image "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.operator_catalog_image"* ]]
}

# operator profiling

@test "invoke run-tests with operator_profiling" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_profiling --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.operator_profiling" ]]
}

@test "invoke run-tests without operator_profiling" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.operator_profiling"* ]]
}

@test "invoke run-tests with operator_profiling_data_access_yaml_uri" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_profiling_data_access_yaml_uri uri --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.operator_profiling_data_access_yaml_uri=uri" ]]
}

@test "invoke run-tests with operator_profiling_data_access_yaml_uri missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_profiling_data_access_yaml_uri --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.operator_profiling_data_access_yaml_uri"* ]]
}

@test "invoke run-tests with operator_profiling_data_access_yaml_uri empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_profiling_data_access_yaml_uri "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.operator_profiling_data_access_yaml_uri"* ]]
}

@test "invoke run-tests with operator_profiling_output_file_uri" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_profiling_output_file_uri uri --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.operator_profiling_output_file_uri=uri" ]]
}

@test "invoke run-tests with operator_profiling_output_file_uri missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_profiling_output_file_uri --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.operator_profiling_output_file_uri"* ]]
}

@test "invoke run-tests with operator_profiling_output_file_uri empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_profiling_output_file_uri "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.operator_profiling_output_file_uri"* ]]
}

# files/binaries

@test "invoke run-tests with operator_yaml_uri" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_yaml_uri file.yaml --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.operator_yaml_uri=file.yaml" ]]
}

@test "invoke run-tests with operator_yaml_uri missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_yaml_uri --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.operator_yaml_uri"* ]]
}

@test "invoke run-tests with operator_yaml_uri empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --operator_yaml_uri "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.operator_yaml_uri"* ]]
}

@test "invoke run-tests with cli_path" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --cli_path cli --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.cli_path=cli" ]]
}

@test "invoke run-tests with cli_path missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --cli_path --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.cli_path"* ]]
}

@test "invoke run-tests with cli_path empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --cli_path "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.cli_path"* ]]
}

# runtime

@test "invoke run-tests with services_image_tag" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --services_image_tag registry --dry_run
    [ "$status" -eq 1 ]
    [[ "${output}" != *"--tests.services_image_tag"* ]]
}

@test "invoke run-tests with services_{}_image_tag" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --services_anything_image_tag registry --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.services_anything_image_tag=registry" ]]
}

@test "invoke run-tests with services_{}_image_tag missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --services_anything_image_tag --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.services_anything_image_tag"* ]]
}

@test "invoke run-tests with services_{}_image_tag empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --services_anything_image_tag "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.services_anything_image_tag"* ]]
}

@test "invoke run-tests with runtime_application_image_registry" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --runtime_application_image_registry registry --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.runtime_application_image_registry=registry" ]]
}

@test "invoke run-tests with runtime_application_image_registry missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --runtime_application_image_registry --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.runtime_application_image_registry"* ]]
}

@test "invoke run-tests with runtime_application_image_registry empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --runtime_application_image_registry "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.runtime_application_image_registry"* ]]
}

@test "invoke run-tests with runtime_application_image_name_prefix" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --runtime_application_image_name_prefix prefix --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.runtime_application_image_name_prefix=prefix" ]]
}

@test "invoke run-tests with runtime_application_image_name_prefix missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --runtime_application_image_name_prefix --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.runtime_application_image_name_prefix"* ]]
}

@test "invoke run-tests with runtime_application_image_name_prefix empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --runtime_application_image_name_prefix "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.runtime_application_image_name_prefix"* ]]
}

@test "invoke run-tests with runtime_application_image_name_suffix" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --runtime_application_image_name_suffix suffix --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.runtime_application_image_name_suffix=suffix" ]]
}

@test "invoke run-tests with runtime_application_image_name_suffix missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --runtime_application_image_name_suffix --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.runtime_application_image_name_suffix"* ]]
}

@test "invoke run-tests with runtime_application_image_name_suffix empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --runtime_application_image_name_suffix "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.runtime_application_image_name_suffix"* ]]
}

@test "invoke run-tests with runtime_application_image_version" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --runtime_application_image_version latest --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.runtime_application_image_version=latest" ]]
}

@test "invoke run-tests with runtime_application_image_version missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --runtime_application_image_version --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.runtime_application_image_version"* ]]
}

@test "invoke run-tests with runtime_application_image_version empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --runtime_application_image_version "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.runtime_application_image_version"* ]]
}

# build

@test "invoke run-tests with custom_maven_repo_url" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --custom_maven_repo_url repourl --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.custom_maven_repo_url=repourl" ]]
}

@test "invoke run-tests with custom_maven_repo_url missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --custom_maven_repo_url --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.custom_maven_repo_url"* ]]
}

@test "invoke run-tests with custom_maven_repo_url empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --custom_maven_repo_url "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.custom_maven_repo_url"* ]]
}

@test "invoke run-tests with custom_maven_repo_replace_default" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --custom_maven_repo_replace_default --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.custom_maven_repo_replace_default" ]]
}

@test "invoke run-tests without custom_maven_repo_replace_default" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.custom_maven_repo_replace_default"* ]]
}

@test "invoke run-tests with maven_mirror_url" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --maven_mirror_url maven --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.maven_mirror_url=maven" ]]
}

@test "invoke run-tests with maven_mirror_url missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --maven_mirror_url --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.maven_mirror_url"* ]]
}

@test "invoke run-tests with maven_mirror_url empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --maven_mirror_url "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.maven_mirror_url"* ]]
}

@test "invoke run-tests with maven_ignore_self_signed_certificate" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --maven_ignore_self_signed_certificate --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.maven_ignore_self_signed_certificate" ]]
}

@test "invoke run-tests without maven_ignore_self_signed_certificate" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.maven_ignore_self_signed_certificate"* ]]
}

@test "invoke run-tests with build_builder_image_tag" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --build_builder_image_tag tag --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.build_builder_image_tag=tag" ]]
}

@test "invoke run-tests with build_builder_image_tag missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --build_builder_image_tag --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.build_builder_image_tag"* ]]
}

@test "invoke run-tests with build_builder_image_tag empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --build_builder_image_tag "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.build_builder_image_tag"* ]]
}

@test "invoke run-tests with build_runtime_jvm_image_tag" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --build_runtime_jvm_image_tag tag --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.build_runtime_jvm_image_tag=tag" ]]
}

@test "invoke run-tests with build_runtime_jvm_image_tag missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --build_runtime_jvm_image_tag --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.build_runtime_jvm_image_tag"* ]]
}

@test "invoke run-tests with build_runtime_jvm_image_tag empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --build_runtime_jvm_image_tag "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.build_runtime_jvm_image_tag"* ]]
}

@test "invoke run-tests with build_runtime_native_image_tag" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --build_runtime_native_image_tag tag --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.build_runtime_native_image_tag=tag" ]]
}

@test "invoke run-tests with build_runtime_native_image_tag missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --build_runtime_native_image_tag --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.build_runtime_native_image_tag"* ]]
}

@test "invoke run-tests with build_runtime_native_image_tag empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --build_runtime_native_image_tag "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.build_runtime_native_image_tag"* ]]
}

@test "invoke run-tests with disable_maven_native_build_container" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --disable_maven_native_build_container --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.disable_maven_native_build_container" ]]
}

@test "invoke run-tests without disable_maven_native_build_container" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.disable_maven_native_build_container"* ]]
}

@test "invoke run-tests with native_builder_image" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --native_builder_image image --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.native_builder_image=image" ]]
}

@test "invoke run-tests with native_builder_image missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --native_builder_image --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.native_builder_image"* ]]
}

@test "invoke run-tests with native_builder_image empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --native_builder_image "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.native_builder_image"* ]]
}

# examples repository

@test "invoke run-tests with examples_uri" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --examples_uri uri --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.examples_uri=uri" ]]
}

@test "invoke run-tests with examples_uri missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --examples_uri --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.examples_uri"* ]]
}

@test "invoke run-tests with examples_uri empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --examples_uri "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.examples_uri"* ]]
}

@test "invoke run-tests with examples_ref" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --examples_ref ref --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.examples_ref=ref" ]]
}

@test "invoke run-tests with examples_ref missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --examples_ref --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.examples_ref"* ]]
}

@test "invoke run-tests with examples_ref empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --examples_ref "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.examples_ref"* ]]
}

# Infinispan

@test "invoke run-tests with infinispan_installation_source" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --infinispan_installation_source yaml --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.infinispan_installation_source=yaml" ]]
}

@test "invoke run-tests with infinispan_installation_source missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --infinispan_installation_source --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.infinispan_installation_source"* ]]
}

@test "invoke run-tests with infinispan_installation_source empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --infinispan_installation_source "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.infinispan_installation_source"* ]]
}

# Hyperfoil

@test "invoke run-tests with hyperfoil_output_directory" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --hyperfoil_output_directory /some/folder --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.hyperfoil_output_directory=/some/folder" ]]
}

@test "invoke run-tests with hyperfoil_output_directory missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --hyperfoil_output_directory --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.hyperfoil_output_directory"* ]]
}

@test "invoke run-tests with hyperfoil_output_directory empty value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --hyperfoil_output_directory "" --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.hyperfoil_output_directory"* ]]
}

# dev options

@test "invoke run-tests with show_scenarios" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --show_scenarios --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.show_scenarios" ]]
}

@test "invoke run-tests with keep_namespace" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --keep_namespace --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.keep_namespace" ]]
}

@test "invoke run-tests without keep_namespace" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.keep_namespace"* ]]
}

@test "invoke run-tests with namespace_name" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --namespace_name test-namespace --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.dev.namespace_name=test-namespace" ]]
}

@test "invoke run-tests with namespace_name missing value" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --namespace_name --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.dev.namespace_name"* ]]
}

@test "invoke run-tests with local_cluster" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --local_cluster --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" =~ "--tests.dev.local_cluster" ]]
}

@test "invoke run-tests without local_cluster" {
    run ${BATS_TEST_DIRNAME}/run-tests.sh --dry_run
    [ "$status" -eq 0 ]
    [[ "${output}" != *"--tests.dev.local_cluster"* ]]
}