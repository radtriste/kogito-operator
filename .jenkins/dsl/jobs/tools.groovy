import org.kie.jenkins.jobdsl.templates.KogitoJobTemplate
import org.kie.jenkins.jobdsl.KogitoConstants
import org.kie.jenkins.jobdsl.Utils

folder(KogitoConstants.KOGITO_DSL_TOOLS_FOLDER)

Map defaultJobParams = [
    job: [
        name: 'kogito-cloud-operator',
        folder: KogitoConstants.KOGITO_DSL_TOOLS_FOLDER
    ],
    git: [
        author: "${GIT_AUTHOR_NAME}",
        branch: "${GIT_BRANCH}",
        repository: 'kogito-cloud-operator',
        credentials: "${GIT_AUTHOR_CREDENTIALS_ID}",
        token_credentials: "${GIT_AUTHOR_TOKEN_CREDENTIALS_ID}"
    ]
]

// Clean old namespaces
def copyManifestsJobParams = Utils.deepCopyObject(defaultJobParams)
copyManifestsJobParams.job.name = 'kogito-operator-copy-manifests-files'
copyManifestsJobParams.jenkinsfile = '.jenkins/Jenkinsfile.copy_csv_files'
KogitoJobTemplate.createPipelineJob(this, copyManifestsJobParams).with {
    parameters {
        stringParam('DISPLAY_NAME', '', 'Setup a specific build display name')
        
        stringParam('GIT_AUTHOR', 'kiegroup', 'Which Git author repository ?')
        stringParam('MANIFESTS_VERSION', '', 'Which version of manifests do you want to copy to master ?')
    }
}