import org.kie.jenkins.jobdsl.templates.KogitoJobTemplate
import org.kie.jenkins.jobdsl.KogitoConstants
import org.kie.jenkins.jobdsl.Utils

branchFolder = "${KogitoConstants.KOGITO_DSL_NIGHTLY_RELEASE_FOLDER}/${JOB_BRANCH_FOLDER}"

folder(KogitoConstants.KOGITO_DSL_NIGHTLY_RELEASE_FOLDER)
folder(branchFolder)

defaultJobParams = [
    job: [
        name: 'kogito-cloud-operator',
        folder: branchFolder
    ],
    git: [
        author: "${GIT_AUTHOR_NAME}",
        branch: "${GIT_BRANCH}",
        repository: 'kogito-cloud-operator',
        credentials: "${GIT_AUTHOR_CREDENTIALS_ID}",
        token_credentials: "${GIT_AUTHOR_TOKEN_CREDENTIALS_ID}"
    ]
]

def getJobParams(String jobName, String jobDescription, String jenkinsfileName){
    def jobParams = Utils.deepCopyObject(defaultJobParams)
    jobParams.job.name=jobName
    jobParams.job.description=jobDescription
    jobParams.jenkinsfile=".jenkins/${jenkinsfileName}"
    return jobParams
}

// Deploy pipeline
KogitoJobTemplate.createPipelineJob(this, getJobParams('kogito-operator-deploy', 'Kogito Cloud Operator Deploy', 'Jenkinsfile.deploy')).with {

    // To be replaced later by milestones of Jenkins
    throttleConcurrentBuilds {
        maxTotal(1)
    }

    parameters {
        stringParam('DISPLAY_NAME', '', 'Setup a specific build display name')

        // Build&Test information
        booleanParam('SMOKE_TESTS_ONLY', false, 'If only smoke tests should be run. Default is full testing.')
        booleanParam('SKIP_TESTS', false, 'Skip tests')

        // Deploy information
        booleanParam('IMAGE_USE_OPENSHIFT_REGISTRY', false, 'Set to true if image should be deployed in Openshift registry.In this case, IMAGE_REGISTRY_CREDENTIALS, IMAGE_REGISTRY and IMAGE_NAMESPACE parameters will be ignored')
        stringParam('IMAGE_REGISTRY_CREDENTIALS', "${CLOUD_IMAGE_REGISTRY_CREDENTIALS_NIGHTLY}", 'Image registry credentials to use to deploy images. Will be ignored if no IMAGE_REGISTRY is given')
        stringParam('IMAGE_REGISTRY', "${CLOUD_IMAGE_REGISTRY}", 'Image registry to use to deploy images')
        stringParam('IMAGE_NAMESPACE', "${CLOUD_IMAGE_NAMESPACE}", 'Image namespace to use to deploy images')
        stringParam('IMAGE_NAME_SUFFIX', '', 'Image name suffix to use to deploy images. In case you need to change the final image name, you can add a suffix to it.')
        stringParam('IMAGE_TAG', '', 'Image tag to use to deploy images')

        // Test config if needed specifics. Else test default config will apply.
        booleanParam('KOGITO_IMAGES_IN_OPENSHIFT_REGISTRY', false, 'Set to true if kogito images for tests are in internal Openshift registry.In this case, KOGITO_IMAGES_REGISTRY and KOGITO_IMAGES_NAMESPACE parameters will be ignored')
        stringParam('KOGITO_IMAGES_REGISTRY', "${CLOUD_IMAGE_REGISTRY}", 'Test images registry')
        stringParam('KOGITO_IMAGES_NAMESPACE', "${CLOUD_IMAGE_NAMESPACE}", 'Test images namespace')
        stringParam('KOGITO_IMAGES_NAME_SUFFIX', '', 'Test images name suffix')
        stringParam('KOGITO_IMAGES_TAG', '', 'Test images tag')
        stringParam('EXAMPLES_URI', '', 'Git uri to the kogito-examples repository to use for tests.')
        stringParam('EXAMPLES_REF', '', 'Git reference (branch/tag) to the kogito-examples repository to use for tests.')

        // Release information
        booleanParam('RELEASE', false, 'Is this build for a release?')
        stringParam('PROJECT_VERSION', '', 'Optional if not RELEASE. If RELEASE, cannot be empty.')
    }

    environmentVariables {
        env('JENKINS_EMAIL_CREDS_ID', "${JENKINS_EMAIL_CREDS_ID}")

        env('GIT_BRANCH_NAME', "${GIT_BRANCH}")
        env('GIT_AUTHOR', "${GIT_AUTHOR_NAME}")
        env('GIT_AUTHOR_CREDS_ID', "${GIT_AUTHOR_CREDENTIALS_ID}")
        env('GITHUB_TOKEN_CREDS_ID', "${GIT_AUTHOR_TOKEN_CREDENTIALS_ID}")
        env('BOT_AUTHOR', "${GIT_BOT_AUTHOR_CREDENTIALS_ID}")
        env('BOT_AUTHOR_CREDS_ID', "${GIT_BOT_AUTHOR_CREDENTIALS_ID}")

        env('DEFAULT_STAGING_REPOSITORY', "${MAVEN_NEXUS_STAGING_PROFILE_URL}")
        env('MAVEN_ARTIFACT_REPOSITORY', "${MAVEN_ARTIFACTS_REPOSITORY}")
    }
}

// Promote pipeline
KogitoJobTemplate.createPipelineJob(this, getJobParams('kogito-operator-promote', 'Kogito Cloud Operator Promote', 'Jenkinsfile.promote')).with {
    parameters {
        stringParam('DISPLAY_NAME', '', 'Setup a specific build display name')

        // Deploy job url to retrieve deployment.properties
        stringParam('DEPLOY_BUILD_URL', '', 'URL to jenkins deploy build to retrieve the `deployment.properties` file. If base parameters are defined, they will override the `deployment.properties` information')
        
        // Base information which can override `deployment.properties`
        booleanParam('BASE_IMAGE_USE_OPENSHIFT_REGISTRY', false, 'Override `deployment.properties`. Set to true if base image should be deployed in Openshift registry.In this case, BASE_IMAGE_REGISTRY_CREDENTIALS, BASE_IMAGE_REGISTRY and BASE_IMAGE_NAMESPACE parameters will be ignored')
        stringParam('BASE_IMAGE_REGISTRY_CREDENTIALS', "${CLOUD_IMAGE_REGISTRY_CREDENTIALS_NIGHTLY}", 'Override `deployment.properties`. Base Image registry credentials to use to deploy images. Will be ignored if no BASE_IMAGE_REGISTRY is given')
        stringParam('BASE_IMAGE_REGISTRY', "${CLOUD_IMAGE_REGISTRY}", 'Override `deployment.properties`. Base image registry')
        stringParam('BASE_IMAGE_NAMESPACE', "${CLOUD_IMAGE_NAMESPACE}", 'Override `deployment.properties`. Base image namespace')
        stringParam('BASE_IMAGE_NAME_SUFFIX', '', 'Override `deployment.properties`. Base image name suffix')
        stringParam('BASE_IMAGE_TAG', '', 'Override `deployment.properties`. Base image tag')

        // Promote information
        booleanParam('PROMOTE_IMAGE_USE_OPENSHIFT_REGISTRY', false, 'Set to true if base image should be deployed in Openshift registry.In this case, PROMOTE_IMAGE_REGISTRY_CREDENTIALS, PROMOTE_IMAGE_REGISTRY and PROMOTE_IMAGE_NAMESPACE parameters will be ignored')
        stringParam('PROMOTE_IMAGE_REGISTRY_CREDENTIALS', "${CLOUD_IMAGE_REGISTRY_CREDENTIALS_NIGHTLY}", 'Promote Image registry credentials to use to deploy images. Will be ignored if no PROMOTE_IMAGE_REGISTRY is given')
        stringParam('PROMOTE_IMAGE_REGISTRY', "${CLOUD_IMAGE_REGISTRY}", 'Promote image registry')
        stringParam('PROMOTE_IMAGE_NAMESPACE', "${CLOUD_IMAGE_NAMESPACE}", 'Promote image namespace')
        stringParam('PROMOTE_IMAGE_NAME_SUFFIX', '', 'Promote image name suffix')
        stringParam('PROMOTE_IMAGE_TAG', '', 'Promote image tag')
        booleanParam('DEPLOY_WITH_LATEST_TAG', false, 'Set to true if you want the deployed images to also be with the `latest` tag')

        // Release information which can override  `deployment.properties`
        booleanParam('RELEASE', false, 'Override `deployment.properties`. Is this build for a release?')
        stringParam('PROJECT_VERSION', '', 'Override `deployment.properties`. Optional if not RELEASE. If RELEASE, cannot be empty.')
        stringParam('GIT_TAG', '', 'Git tag to set, if different from v{PROJECT_VERSION}')
    }
    
    environmentVariables {
        env('JENKINS_EMAIL_CREDS_ID', "${JENKINS_EMAIL_CREDS_ID}")

        env('GIT_BRANCH_NAME', "${GIT_BRANCH}")
        env('GIT_AUTHOR', "${GIT_AUTHOR_NAME}")
        env('GIT_AUTHOR_CREDS_ID', "${GIT_AUTHOR_CREDENTIALS_ID}")
        env('GITHUB_TOKEN_CREDS_ID', "${GIT_AUTHOR_TOKEN_CREDENTIALS_ID}")
        env('BOT_AUTHOR', "${GIT_BOT_AUTHOR_CREDENTIALS_ID}")
        env('BOT_AUTHOR_CREDS_ID', "${GIT_BOT_AUTHOR_CREDENTIALS_ID}")
    }
}