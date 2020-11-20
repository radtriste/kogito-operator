import org.kie.jenkins.jobdsl.templates.KogitoJobTemplate
import org.kie.jenkins.jobdsl.KogitoConstants
import org.kie.jenkins.jobdsl.Utils

folder(KogitoConstants.KOGITO_DSL_PULLREQUEST_FOLDER)

Map defaultJobParams = [
    job: [
        name: 'kogito-cloud-operator',
        folder: KogitoConstants.KOGITO_DSL_PULLREQUEST_FOLDER
    ],
    git: [
        author: "${GIT_AUTHOR_NAME}",
        branch: "${GIT_BRANCH}",
        repository: 'kogito-cloud-operator',
        credentials: "${GIT_AUTHOR_CREDENTIALS_ID}",
        token_credentials: "${GIT_AUTHOR_TOKEN_CREDENTIALS_ID}"
    ]
]

// Default Build&Test PR check job
def prCheckParams = Utils.deepCopyObject(defaultJobParams)
KogitoJobTemplate.createPRJob(this, prCheckParams)