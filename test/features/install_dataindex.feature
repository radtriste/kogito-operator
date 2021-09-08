@dataindex
@kafka
Feature: Kogito Data Index

  Background:
    Given Namespace is created
    And Kogito Operator is deployed
    And Kafka Operator is deployed
    And Kafka instance "kogito-kafka" is deployed
    And Install Kafka Kogito Infra "kafka" targeting service "kogito-kafka" within 5 minutes

  @smoke
  Scenario: Install Kogito Data Index with Infinispan
    Given Infinispan Operator is deployed
    And Infinispan instance "kogito-infinispan" is deployed with configuration:
      | username | developer |
      | password | mypass    |
    And Install Infinispan Kogito Infra "infinispan" targeting service "kogito-infinispan" within 5 minutes

    When Install Kogito Data Index with 1 replicas with configuration:
      | config | database-type | Infinispan               |
      | config | infra         | infinispan               |
      | config | infra         | kafka                    |

    Then Kogito Data Index has 1 pods running within 10 minutes
    And GraphQL request on service "data-index" is successful within 2 minutes with path "graphql" and query:
    """
    {
      ProcessInstances{
        id
      }
    }
    """

#####
# For infinispan/mongodb external component, we cannot merge in one scenario outline
# due to the added `database` field in external config

  @mongodb
  Scenario: Install Kogito Data Index with persistence using external MongoDB
    Given MongoDB Operator is deployed
    And MongoDB instance "kogito-mongodb" is deployed with configuration:
      | username | developer            |
      | password | mypass               |
      | database | kogito_dataindex     |
    And Install MongoDB Kogito Infra "mongodb" targeting service "kogito-mongodb" within 5 minutes with configuration:
      | config   | username | developer            |
      | config   | database | kogito_dataindex     |

    When Install Kogito Data Index with 1 replicas with configuration:
      | config | database-type | MongoDB  |
      | config | infra         | mongodb  |
      | config | infra         | kafka    |

    Then Kogito Data Index has 1 pods running within 10 minutes
    And GraphQL request on service "data-index" is successful within 2 minutes with path "graphql" and query:
    """
    {
      ProcessInstances{
        id
      }
    }
    """

#####

  @postgresql
  Scenario: Install Kogito Data Index with PostgreSQL
    Given PostgreSQL instance "postgresql" is deployed within 3 minutes with configuration:
      | username | myuser |
      | password | mypass |
      | database | mydb   |

    When Install Kogito Data Index with 1 replicas with configuration:
      | config      | database-type                             | PostgreSQL                             |
      | config      | infra                                     | kafka                                  |
      | runtime-env | QUARKUS_DATASOURCE_JDBC_URL               | jdbc:postgresql://postgresql:5432/mydb |
      | runtime-env | QUARKUS_DATASOURCE_USERNAME               | myuser                                 |
      | runtime-env | QUARKUS_DATASOURCE_PASSWORD               | mypass                                 |
      | runtime-env | QUARKUS_HIBERNATE_ORM_DATABASE_GENERATION | update                                 |

    Then Kogito Data Index has 1 pods running within 10 minutes
    And GraphQL request on service "data-index" is successful within 2 minutes with path "graphql" and query:
    """
    {
      ProcessInstances{
        id
      }
    }
    """

#####

  @failover
  @events
  @infinispan
  @kafka
  @test
  Scenario Outline: Test Kogito Data Index failover with Infinispan
    Given Infinispan Operator is deployed
    And Infinispan instance "kogito-infinispan" is deployed with configuration:
      | username | developer |
      | password | mypass    |
    And Install Infinispan Kogito Infra "infinispan" targeting service "kogito-infinispan" within 5 minutes
    And Install Kogito Data Index with 1 replicas with configuration:
      | config | infra | infinispan |
      | config | infra | kafka      |
    And Clone Kogito examples into local directory
    And Local example service "process-quarkus-example" is built by Maven and deployed to runtime registry with Maven configuration:
      | profile | persistence,events |

    When Deploy quarkus example service "process-quarkus-example" from runtime registry with configuration:
      | config | infra | infinispan |
      | config | infra | kafka      |
    And Kogito Runtime "process-quarkus-example" has 1 pods running within 10 minutes
    And Start "orders" process on service "process-quarkus-example" within 3 minutes with body:
      """json
      {
        "approver" : "john",
        "order" : {
          "orderNumber" : "12345",
          "shipped" : false
        }
      }
      """

    Then Service "process-quarkus-example" contains 1 instances of process with name "orders"
    Then GraphQL request on Data Index service returns 1 instance of process with name "orders" within 2 minutes

    When Scale Infinispan instance "kogito-infinispan" to 0 pods within 2 minutes
    Then GraphQL request on Data Index service returns 0 instances of process with name "orders" within 2 minutes

    When Scale Infinispan instance "kogito-infinispan" to 1 pods within 2 minutes
    Then GraphQL request on Data Index service returns 1 instances of process with name "orders" within 2 minutes

    When Start "orders" process on service "process-quarkus-example" within 3 minutes with body:
      """json
      {
        "approver" : "john",
        "order" : {
          "orderNumber" : "12345",
          "shipped" : false
        }
      }
      """
    Then Service "process-quarkus-example" contains 2 instances of process with name "orders"
    And GraphQL request on Data Index service returns 2 instances of process with name "orders" within 2 minutes

# External Kafka testing is covered in deploy_quarkus_service and deploy_springboot_service as it checks integration between Data index and KogitoRuntime