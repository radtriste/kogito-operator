Feature: Service Deployment: Quarkus with persistence

  Background:
    Given Kogito Operator is deployed with dependencies

  Scenario Outline: Deploy jbpm-quarkus-example service
    Given Deploy quarkus example service "jbpm-quarkus-example" with persistence enabled and native <native>
    And Call HTTP "GET" request with path "orders" on service "jbpm-quarkus-example" is successful within <minutes> minutes
    
    When Call HTTP "POST" request on service "jbpm-quarkus-example" with path "orders" and "json" body '{"approver" : "john", "order" : {"orderNumber" : "12345", "shipped" : false}}'
    And Scale DeploymentConfig "jbpm-quarkus-example" to 0 pods
    And Scale DeploymentConfig "jbpm-quarkus-example" to 1 pods
    
    Then Call HTTP "GET" request with path "orders" on service "jbpm-quarkus-example" should return an array of size 1
    
    Examples:
      | native | minutes |
      | "enabled" | 20 |
      | "disabled" | 10 |